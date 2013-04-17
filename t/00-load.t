#!perl -T

use strict;
use warnings FATAL => 'all';

use Test::More;

plan tests => 1;

BEGIN {
    use_ok('PerlDiver') || print "Bail out!\n";
}

diag("Testing PerlDiver $PerlDiver::VERSION, Perl $], $^X");
