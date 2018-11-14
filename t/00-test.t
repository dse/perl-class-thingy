# -*- perl -*-
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
    public builder;
    public default3, sub_default => sub {
        my ($self) = @_;
        $self->builder(1);
        return 5;
    };
    public default4, lazy_default => sub {
        my ($self) = @_;
        $self->builder(2);
        state $count = 0;
        warn("$count\n");
        return ($count += 1);
    };
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

    plan tests => 25;

    my $a1 = My::Test::Class->new();
    my $a2 = My::Test::Class->new(foo => 5);
    my $a3 = My::Test::Class->new({ foo => 5 });
    my $a4 = My::Test::Class::Child->new();

    ok(!defined $a1->foo, "test 1");
    ok($a1->builder == 1, "test 1.5");
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
    ok($a1->default3 == 5, "test 18");
    ok($a4->default3 == 5, "test 19");

    ok($a1->builder == 1, "test 19.5");
    ok($a1->default4 == 1, "test 20");
    ok($a1->builder == 2, "test 20.5");
    ok($a4->default4 == 2, "test 21");
    $a2->default4(5);
    ok($a2->default4() == 5, "test 22");
};
