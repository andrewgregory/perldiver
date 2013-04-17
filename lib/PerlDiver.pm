package PerlDiver;
our $VERSION = '0.01';

use Carp;

use PerlDiver::MetaCPAN;
use PerlDiver::Local;

=head1 NAME

PerlDiver - command line interface for browsing perl modules

=cut

sub new {
    my ( $class, %self ) = @_;
    bless \%self, $class;
}

1;
