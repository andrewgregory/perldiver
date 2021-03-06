package PerlDiver::MetaCPAN;
use parent 'PerlDiver::Base';

use strict;
use warnings;

our $VERSION = '0.1';

use JSON;
use LWP::Simple;

use URI::Escape qw(uri_escape);

my $default_url = 'http://api.metacpan.org/v0';

sub url {
    my ($self) = @_;
    return ($self->{url} or $default_url);
}

sub pod {
    my ( $self, $target ) = @_;
    my $query_url = sprintf( '%s/pod/%s?content-type=text/x-pod',
        $self->url, uri_escape($target) );
    return get($query_url);
}

sub search {
    my ( $self, @targets ) = @_;
    my $query = uri_escape( join( ' ', map {qq("$_")} @targets ) );
    my $query_url
      = sprintf( '%s/release/_search?size=10&q=status:latest AND %s',
        $self->url, $query );
    my $response = get($query_url);
    my @results  = map {
        $_->{_source}->{distribution} =~ s/-/::/g;
        $_->{_source};
    } @{ decode_json($response)->{hits}->{hits} };
    return @results;
}

sub source {
    my ($self, $target) = @_;
    my $query_url = sprintf( '%s/source/%s',
        $self->url, uri_escape($target) );
    my $source = get($query_url) or return;
    return ($source, 'pl');
}

1;
