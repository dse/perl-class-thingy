package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use base 'Exporter';
our @EXPORT    = qw(public);
our @EXPORT_OK = qw(public);

use mro;

use constant CTO => 'Class::Thingy::Object';

# list of non-lazy builders to call by class on object initialization.
our %builder;

# when another module calls:
#
#     use Class::Thingy;
#
# this is called.
sub import {
    my $class = caller;

    # make this class a subclass of C::T::O.
    if (!$class->isa(CTO)) {
        require Class::Thingy::Object;
        my $isa_var_name = "${class}::ISA";
        no strict 'refs';
        push(@{$isa_var_name}, CTO);
    }

    # remove redundant instances of C::T::O from MRO.
    my $rev_classs = mro::get_isarev($class);
    foreach my $rev_class (@$rev_classs) {
        my $isa_var_name = "${class}::ISA";
        no strict 'refs';
        @{$isa_var_name} = grep { $_ ne CTO } @{$isa_var_name};
    }

    # Go to the original import method.
    my $super_import = $class->can('SUPER::import');
    goto &$super_import if $super_import;
}

sub public(*;@) {
    my ($method, %args) = @_;
    my $class = caller;
    my $sub_name = "${class}::${method}";

    local *legacy = sub {
        my ($old, $new) = @_;
        if (exists $args{$old}) {
            return $args{$new} = delete $args{$old};
        }
        return;
    };

    if (defined legacy(lazy_default => 'builder')) {
        $args{lazy} = 1;
    }
    if (defined legacy(sub_default => 'builder')) {
        $args{lazy} = 0;
    }
    legacy(delete => 'delete_name');

    if (defined $args{delegate}) {
        my $delegate = $args{delegate};
        my $method = $args{method} // $method;
        my $sub = sub {
            my $self = shift;
            return $self->$delegate->$method(@_);
        };
        { no strict 'refs'; *{$sub_name} = $sub; }
        return;
    }

    my $set           = $args{set};
    my $after_set     = $args{after_set};
    my $get           = $args{get};
    my $builder       = $args{builder};
    my $after_builder = $args{after_builder};
    my $lazy          = $args{lazy};
    my $has_default   = exists $args{default};
    my $default       = $args{default};

    if (!$lazy) {
        my $cto_builder_sub_name = "${class}::_cto_builder";
        my $cto_builder_sub = $class->can('_cto_builder');
        if (!$cto_builder_sub) {
            $cto_builder_sub = sub {
                my ($self) = @_;
                foreach my $builder (@{$builder{$class}}) {
                    $self->$builder();
                }
                $self->SUPER::_cto_builder if $self->can('SUPER::_cto_builder');
            };
            { no strict 'refs';
              *{$cto_builder_sub_name} = $cto_builder_sub; }
        }
        push(@{$builder{$class}}, $method);
    }

    my $getter_sub = sub {
        my $self = $_[0];
        if (exists $self->{$method}) {
            if ($get && (eval { ref $get eq 'CODE' } || $self->can($get))) {
                return $self->$get($self->{$method});
            } else {
                return $self->{$method};
            }
        }
        if ($builder && (eval { ref $builder eq 'CODE' } || $self->can($builder))) {
            my $result = $self->{$method} = $self->$builder();
            if ($after_builder && (eval { ref $after_builder eq 'CODE' } || $self->can($after_builder))) {
                $self->$after_builder();
            }
            return $result;
        }
        if ($has_default) {
            return $self->{$method} = $default;
        }
        return;
    };

    my $setter_sub = sub {
        my $self = $_[0];
        if ($set && (eval { ref $set eq 'CODE' } || $self->can($set))) {
            return $self->{$method} = $self->$set($_[1]);
        } else {
            return $self->{$method} = $_[1];
        }
    };

    my $sub = sub {
        goto $setter_sub if scalar @_ >= 2;
        goto $getter_sub;
    };

    { no strict 'refs'; *{$sub_name} = $sub; }

    my $getter_name = $args{getter_name};
    my $setter_name = $args{setter_name};

    if (defined $getter_name) {
        my $getter_sub_name = "${class}::${getter_name}";
        no strict 'refs';
        *{$getter_sub_name} = $getter_sub;
    }
    if (defined $setter_name) {
        my $setter_sub_name = "${class}::${setter_name}";
        no strict 'refs';
        *{$setter_sub_name} = $setter_sub;
    }

    my $raw_accessor_name = $args{raw_accessor_name};
    if (defined $raw_accessor_name) {
        my $sub_name = "${class}::${raw_accessor_name}";
        my $sub = sub {
            my $self = $_[0];
            if (scalar @_ >= 2) {
                return $self->{$method} = $_[1];
            }
            if (exists $self->{$method}) {
                return $self->{$method};
            }
            return;
        };
        { no strict 'refs'; *{$sub_name} = $sub; }
    }

    my $delete_name = $args{delete_name};
    if (defined $delete_name) {
        my $sub_name = "${class}::${delete_name}";
        my $sub = sub {
            my $self = $_[0];
            return delete $self->{$method};
        };
        { no strict 'refs'; *{$sub_name} = $sub; }
    }
}

=head1 NAME

Class::Thingy - Another object framework

=head1 SYNOPSIS

    package My::Class;
    use Class::Thingy;

    public 'x';
    public 'y';

    sub init {
        my ($self) = @_;
    }

=head1 DESCRIPTION

=head1 PROPERTY ATTRIBUTES

=head2 default

    public 'x', 'default' => 50;

Specifies a default value for an object's property.

=head2 builder

    public 'foo', 'builder' => sub {
        my ($self) = @_;
        my $value;
        #
        # run some code to set $value.
        #
        return $value;
    };

Specifies a subroutine that returns a default value for an object's
property.

=head2 lazy

    public 'foo', 'lazy' => 1, 'builder' => sub {
        my ($self) = @_;
        my $value;
        #
        # run some code to set $value.
        #
        return $value;
    };

Wait until the getter is first used before running the builder.

=head2 set

    public 'foo', 'set' => sub {
        my ($self, $value) = @_; # receives the value passed to the setter
        #
        # run some code.  you can change $value.
        #
        return $value;           # specifies the property's new value
    };

Code to run before setting a property's value.

=head2 get

    public 'foo', 'get' => sub {
        my ($self, $value) = @_; # receives the property's value
        #
        # run some code.  you can change $value.
        #
        return $value;           # returned by the getter to the caller
    };

Code to run after fetching a property's value and before returning to
the caller.

=head2 after_builder

    public 'foo', 'builder' => sub {
        ...
    }, 'after_builder' => sub {
        my ($self) = @_;
        #
        # run some code.
        #
    };

Code to run after a builder is executed, before returning to the
caller.

=head2 delegate

    public 'foo', 'delegate' => 'bar';

$object->foo effectively becomes $object->bar->foo.

=head2 method

    public 'foo', 'delegate' => 'bar', 'method' => 'woof';

$object->foo effectively becomes $object->bar->woof.

=head2 delete

    public 'foo', 'delete' => 'deleteFoo';

Create a method, 'deleteFoo' in this example, to delete an object's
property.  If the property is accessed via setter again and a builder
is specified, the builder will be executed again to set the property's
value.

=cut

1;
