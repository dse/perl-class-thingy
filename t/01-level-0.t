# -*- perl -*-
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";
use Class::Thingy::Level::0;
use Class::Thingy::Level::0::Test::A;
use Class::Thingy::Level::0::Test::B;

package main {
    use Test::More;
    use Data::Dumper;

    my $attr;
    my $o;

    $o = Class::Thingy::Level::0::Test::A->new();
    ok($o);
    ok(!defined $o->attr);
    $attr = $o->attr(25);
    ok(defined $o->attr);
    ok($attr == 25);
    $attr = $o->attr;
    ok($attr == 25);
    $attr = $o->setAttr(35);
    ok($attr == 35);
    $attr = $o->getAttr();
    ok($attr == 35);

    $o = Class::Thingy::Level::0::Test::B->new(attr => 65);
    ok($o);
    ok(!defined $o->attr);
    $attr = $o->attr(25);
    ok(defined $o->attr);
    ok($attr == 25);
    $attr = $o->attr;
    ok($attr == 25);
    $attr = $o->setAttr(35);
    ok($attr == 35);
    $attr = $o->getAttr();
    ok($attr == 35);

    done_testing();
};

1;
