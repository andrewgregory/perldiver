use strict;
use warnings;

package PerlDiver::MetaCPAN;
use parent 'PerlDiver';

use JSON;
use LWP::Simple;

sub new {
    my ( $class, %self ) = @_;
    bless \%self, $class;
}

sub pod {
    my ( $self, $target ) = @_;
    my $query_url
      = sprintf( '%s/pod/%s?content-type=text/x-pod', $self->{url}, $target );
    return get($query_url)
      or die "Could not retrieve documentation for module '$target'.\n";
}

sub search {
    my ( $self, $query ) = @_;
    my $query_url
      = sprintf( '%s/release/_search?size=10&q=status:latest AND %s',
        $self->{url}, $query );
    my $response = get($query_url);
    my @results  = map {
        $_->{_source}->{distribution} =~ s/-/::/g;
        $_->{_source};
    } @{ decode_json($response)->{hits}->{hits} };
    return @results;
}

1;
