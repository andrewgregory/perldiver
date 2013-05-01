package PerlDiver::Base;

use strict;
use warnings;

our $VERSION = '0.1';

sub new {
    my ( $class, %self ) = @_;
    bless \%self, $class;
}

1;
