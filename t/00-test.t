#!perl -T
use 5.010;
use strict;
use warnings;

package My::Test::Class {
    use Class::Thingy;
    public foo;
    public bar;
};

package main {
    use Test::More;
    use Data::Dumper;
    print Dumper \@My::Test::Class::ISA;
    my $o;
    $o = My::Test::Class->new();
    print Dumper $o;
    $o = My::Test::Class->new(foo => 5, bar => 10);
    print Dumper $o;
    print Dumper $o->foo;
    print Dumper $o->bar;
    $o->foo(20);
    print Dumper $o;
    print Dumper $o->foo;
    print Dumper $o->bar;
    $o->bar(40);
    print Dumper $o;
    print Dumper $o->foo;
    print Dumper $o->bar;
};
