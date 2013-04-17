use strict;
use warnings;

package PerlDiver::Local;
use parent 'PerlDiver';

use File::Slurp;
use Pod::Find;

sub pod {
    my ( $self, $target ) = @_;
    my $file
      = Pod::Find::pod_where(
        { -inc => 1, -dirs => ['/usr/bin/vendor_perl/'] }, $target )
      or return;
    my $pod = read_file($file);
    return $pod;
}

sub search {
    my ( $self, $query ) = @_;
    Carp::carp("Search not implemented yet");
    return;
}

1;
