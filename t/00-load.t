#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Class::Thingy' ) || print "Bail out!\n";
    use_ok( 'Class::Thingy::Object' ) || print "Bail out!\n";
}

diag( "Testing Class::Thingy $Class::Thingy::VERSION, Perl $], $^X" );
