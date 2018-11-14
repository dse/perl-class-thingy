package Class::Thingy::Object;
use warnings;
use strict;
use v5.10.0;

sub new {
    my $class = shift;
    my $self = bless({}, $class);
    _new_args($self, @_);
    $self->init() if $self->can('init');
    return $self;
}

sub _new_args {
    my $self = shift;
    while (scalar @_) {
        if (ref $_[0] eq 'HASH') {
            my $hashref = shift;
            _new_args($self, %$hashref);
        } elsif (ref $_[0] eq 'ARRAY') {
            my $arrayref = shift;
            _new_args($self, @$arrayref);
        } elsif (scalar @_ >= 2) {
            my $name = shift;
            my $value = shift;
            $self->$name($value);
        } else {
            break;
        }
    }
}

sub SINGLETON {
    my ($self, $class) = @_;
    $class //= caller;
    state %singleton;
    return $singleton{$class} if exists $singleton{$class};
    return $singleton{$class} = $class->new();
}

sub REQUIRE_OBJECT {
    my ($self, $class) = @_;
    $class //= caller;
    return $self if ref $self and $self->isa($class);
    goto &SINGLETON;
}

1;
