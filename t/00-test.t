##!perl -T
use 5.010;
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";

package My::Test::Class {
    use Class::Thingy;
    public foo;
    public bar;

    public default1, default => 1;
    public default2, default => 2;
};

package My::Test::Class::Child {
    use Class::Thingy;
    use base 'My::Test::Class';
    public cat;
    public dog;

    public default2, default => 4;
};

package main {
    use Test::More;
    use Data::Dumper;

    plan tests => 17;

    my $a1 = My::Test::Class->new();
    my $a2 = My::Test::Class->new(foo => 5);
    my $a3 = My::Test::Class->new({ foo => 5 });
    my $a4 = My::Test::Class::Child->new();

    ok(!defined $a1->foo, "test 1");
    ok(!defined $a1->bar, "test 2");
    ok(!defined $a1->foo(), "test 1a");
    ok(!defined $a1->bar(), "test 2a");
    ok($a1->isa("My::Test::Class"), "test 3");
    ok($a1->isa("Class::Thingy::Object"), "test 4");
    ok($a1->foo(5) == 5, "test 5");
    ok($a1->foo == 5, "test 6");
    ok($a1->foo() == 5, "test 7");
    ok($a2->foo == 5, "test 8");
    ok($a2->foo() == 5, "test 9");
    ok(!defined $a2->bar, "test 10");
    ok($a3->foo == 5, "test 11");
    ok($a3->foo() == 5, "test 12");

    ok($a1->default1 == 1, "test 15");
    ok($a1->default2 == 2, "test 16");
    ok($a4->default2 == 4, "test 17");
};
