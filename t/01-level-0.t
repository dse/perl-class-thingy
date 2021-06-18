# -*- perl -*-
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";

package My::Class::0::A {
    use Class::Thingy::Level::0;
    has 'attr';
    sub getAttr {
        my ($self) = @_;
        return $self->attr();
    }
    sub setAttr {
        my ($self, $value) = @_;
        return $self->attr($value);
    }
};

package My::Class::0::B {
    use Class::Thingy::Level::0;
    has 'attr' => (is => 'rw', default => 15);
    sub getAttr {
        my ($self) = @_;
        return $self->attr();
    }
    sub setAttr {
        my ($self, $value) = @_;
        return $self->attr($value);
    }
};

package main {
    use Test::More;
    use Data::Dumper;

    my $attr;
    my $o;

    $o = My::Class::0::A->new();
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

    $o = My::Class::0::B->new(attr => 65);
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
};

1;
