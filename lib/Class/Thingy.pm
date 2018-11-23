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
    my $sub;

    if (defined $args{lazy_default}) {
        $args{builder} = delete $args{lazy_default};
        $args{lazy} = 1;
    }

    if (defined $args{sub_default}) {
        $args{builder} = delete $args{sub_default};
        $args{lazy} = 0;
    }

    if (defined $args{delegate}) {
        my $delegate = $args{delegate};
        my $method = $args{method} // $method;
        $sub = sub {
            my $self = shift;
            return $self->$delegate->$method(@_);
        };
    } else {
        my $set               = $args{set};
        my $get               = $args{get};
        my $has_set           = eval { ref $set eq 'CODE' };
        my $has_get           = eval { ref $get eq 'CODE' };
        my $builder           = $args{builder};
        my $after_builder     = $args{after_builder};
        my $has_builder       = eval { ref $builder       eq 'CODE' };
        my $has_after_builder = eval { ref $after_builder eq 'CODE' };
        my $lazy              = $args{lazy};
        my $has_default       = exists $args{default};
        my $default           = $args{default};

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
                no strict 'refs';
                *{$cto_builder_sub_name} = $cto_builder_sub;
            }
            push(@{$builder{$class}}, $method);
        }

        $sub = sub {
            my $self = shift;
            if (scalar @_) {
                if ($has_set) {
                    return $self->{$method} = $self->$set(shift);
                } else {
                    return $self->{$method} = shift;
                }
            }
            if (exists $self->{$method}) {
                if ($has_get) {
                    return $self->$get($self->{$method});
                } else {
                    return $self->{$method};
                }
            }
            if ($has_builder) {
                my $result = $self->{$method} = $self->$builder();
                if ($has_after_builder) {
                    $self->$after_builder();
                }
                return $result;
            }
            if ($has_default) {
                return $self->{$method} = $default;
            }
            return;
        };
    }

    {
        no strict 'refs';
        *{$sub_name} = $sub;
    }

    my $delete_name = delete $args{delete};
    if (defined $delete_name) {
        my $delete_sub_name = "${class}::${delete_name}";
        my $sub = sub {
            my $self = shift;
            return delete $self->{$method};
        };
        no strict 'refs';
        *{$delete_sub_name} = $sub;
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
