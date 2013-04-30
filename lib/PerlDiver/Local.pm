package PerlDiver::Local;
use parent 'PerlDiver::Base';

use strict;
use warnings;

use File::Slurp;
use Pod::Find;

# Extract a pod section from official documentation

sub _get_pod_section {
    my ( $self, $file, $section ) = @_;
    my $pod   = '';
    my @lines = read_file($file);
    my ( $in_section, $depth ) = ( 0, 0 );
    my $target_re     = qr/^=item(\s+\Q$section\E)/;
    my $target_end_re = qr/^=item(?!\s+\Q$section\E)/;

    for ( my $lineno = 1; $lineno <= @lines; $lineno++ ) {
        my $line = $lines[ $lineno - 1 ];
        if ($in_section) {
            if ( $line =~ /^=over/ ) {
                $depth++;
            }
            elsif ( $line =~ /^=back/ ) {
                if ( $depth == 0 ) {
                    last;
                }
                else {
                    $depth--;
                }
            }
            elsif ( $line =~ $target_end_re and $depth == 0 ) {
                last;
            }
            $pod .= $line;
        }
        elsif ( $line =~ $target_re ) {
            $in_section = 1;

            # add any previous aliases
            for ( my $i = $lineno - 1; $i >= 1; $i-- ) {
                if ( $lines[ $i - 1 ] =~ /^(\s*$|=item\s)/ ) {
                    $pod = $lines[ $i - 1 ] . $pod;
                }
                else {
                    last;
                }
            }
            $pod .= $line;

            # add any following aliases
            for ( $lineno++; $lineno <= @lines; $lineno++ ) {
                if ( $lines[ $lineno - 1 ] =~ /^(\s*$|=item\s)/ ) {
                    $pod .= $lines[ $lineno - 1 ];
                }
                else {
                    $lineno--;
                    last;
                }
            }
        }
        if ( $line !~ /^=item/ and $in_section ) {
            next;
        }
    }
    if ($pod) {
        $pod = "=over\n\n$pod\n\n=back";
    }
    return $pod;
}

sub _builtin_function_pod {
    my ( $self, $function ) = @_;
    my $file = Pod::Find::pod_where( { -inc => 1 }, 'perlfunc' );
    return $self->_get_pod_section( $file, $function );
}

sub pod {
    my ( $self, $target, $opts ) = @_;
    my $pod;
    if ( $opts->{function} ) {
        $pod = $self->_builtin_function_pod($target);
    }
    elsif ( $opts->{variable} ) {
        my $file = Pod::Find::pod_where( { -inc => 1 }, 'perlvar' );
        $pod = $self->_get_pod_section( $file, $target );
    }
    else {
        my $file
          = Pod::Find::pod_where(
            { -inc => 1, -dirs => [ '.', '/usr/bin/vendor_perl/' ] }, $target )
          or return;
        $pod = read_file($file);
    }
    return $pod;
}

sub search {
    my ( $self, @targets ) = @_;
    my %pods = Pod::Find::pod_find( { -script => 1, -inc => 1 } );
    my %matches;
    # FIXME: this is super ugly, refactor it
    foreach my $file ( keys %pods ) {
        my $name = $pods{$file};
        my ( $line, $abstract ) = ( '', '' );
        open my $fh, '<', $file;
        while ( $line = <$fh> ) {
            if ( $line =~ /^=head1\s+NAME/ ) {
                while ( $line = <$fh> ) {
                    next if $line =~ /^\s*$/;    # skip empty lines
                    if ( $line =~ /^\s*\Q$name\E(?:\s|-)*(.*)/i ) {
                        $abstract = $1;
                    }
                    last;
                }
                last;
            }
        }
        close $fh;
        $line = "$name - $abstract";
        my $count = 0;
        foreach my $target (@targets) {
            # this weighting gives decent results in empirical tests
            $count += 1 while ( $line =~ /$target/g );
            $count += 2 while ( $name =~ /\b$target\b/g );
            $count *= 2 if lc $name eq lc $target
        }
        $matches{$name} = {
            score        => $count,
            distribution => $name,
            abstract     => $abstract
        };
    }
    return
      grep { $_->{score} > 0 }
      ( sort { $b->{score} <=> $a->{score} } values %matches );
}

sub source {
    my ( $self, $target ) = @_;
    my $file
      = Pod::Find::pod_where(
        { -inc => 1, -dirs => [ '.', '/usr/bin/vendor_perl/' ] }, $target )
      or return;
    my $source = read_file($file);
    my $ft = ( $file =~ /[.]pod$/i ) ? 'pod' : 'perl';
    return ( $source, $ft );
}

1;
