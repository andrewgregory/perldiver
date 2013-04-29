package PerlDiver::Base;

use strict;
use warnings;

sub new {
    my ( $class, %self ) = @_;
    bless \%self, $class;
}

1;
