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
};

package My::Test::Class::Child {
    use Class::Thingy;
    use base 'My::Test::Class';
    public cat;
    public dog;
};

package main {
    use Test::More;
    plan tests => 7;
    my $a1 = My::Test::Class->new();
    my $a2 = My::Test::Class->new(foo => 5);
    my $a3 = My::Test::Class->new({ foo => 5 });
    ok(!defined $a1->foo, "test 1");
    ok(!defined $a1->bar, "test 2");
    ok($a1->isa("My::Test::Class"), "test 3");
    ok($a1->isa("Class::Thingy::Object"), "test 4");
    ok($a1->foo(5) == 5, "test 5");
    ok($a1->foo == 5, "test 6");
    ok($a1->foo() == 5, "test 7");
};
