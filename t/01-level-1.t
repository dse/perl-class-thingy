# -*- perl -*-
use strict;
use warnings;

use FindBin;
use lib "${FindBin::Bin}/../lib";
# use Class::Thingy::Level::1;

package My::Class::1::A {
    BEGIN {
        use Class::Thingy::Level::1;
    }
    INIT {
        has 'attr';
    }
    sub getAttr {
        my ($self) = @_;
        return $self->attr();
    }
    sub setAttr {
        my ($self, $value) = @_;
        return $self->attr($value);
    }
};

package My::Class::1::B {
    BEGIN {
        use Class::Thingy::Level::1;
    }
    INIT {
        has 'attr' => (is => 'rw', default => 15);
    }
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

    $o = My::Class::1::A->new();
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

    $o = My::Class::1::B->new(attr => 65);
    ok($o);
    ok(defined $o->attr);
    ok($o->attr == 65);
    $attr = $o->attr(25);
    ok(defined $o->attr);
    ok($attr == 25);
    $attr = $o->attr;
    ok($attr == 25);
    $attr = $o->setAttr(35);
    ok($attr == 35);
    $attr = $o->getAttr();
    ok($attr == 35);

    eval {
        my $o = My::Class::1::B->new(invalidAttr => 20);
    };
    ok($@);
    ok($@ =~ m{^\QCan't locate object method "invalidAttr" via package "My::Class::1::B" at \E});

    done_testing();
};

1;
