use strict;
use warnings;

package PerlDiver::Local;
use parent 'PerlDiver';

use File::Slurp;
use Pod::Find;

sub _builtin_function_pod {
    my ($self, $function) = @_;
    my $pod = '';
    my $file = Pod::Find::pod_where( { -inc => 1 }, 'perlfunc' );
    my @lines = read_file($file);
    my ( $in_section, $depth ) = ( 0, 0 );
    my $target_re = qr/^=item(\s+\b\Q$function\E\b)/;
    my $target_end_re = qr/^=item(?!\s+\b\Q$function\E\b)/;

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
            $pod .= $line;
        }
        if ( $line !~ /^=item/ and $in_section ) {
            next;

        }
    }
    if($pod) {
        $pod = "=over\n\n$pod\n\n=back";
    }
    return $pod;
}

sub pod {
    my ( $self, $target, $opts ) = @_;
    my $pod;
    if ( $opts->{function} ) {
        $pod = $self->_builtin_function_pod($target);
    }
    else {
        my $file
          = Pod::Find::pod_where(
            { -inc => 1, -dirs => ['/usr/bin/vendor_perl/'] }, $target )
          or return;
        $pod = read_file($file);
    }
    return $pod;
}

sub search {
    my ( $self, $query ) = @_;
    Carp::carp("Search not implemented yet");
    return;
}

1;
