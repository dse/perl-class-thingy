package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use base 'Exporter';
our @EXPORT    = qw(public);
our @EXPORT_OK = qw(public);

use mro;

use constant CTO => 'Class::Thingy::Object';

our %builder;

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
        my $builder           = $args{builder};
        my $after_builder     = $args{after_builder};
        my $has_builder       = defined $builder       && ref $builder       eq 'CODE';
        my $has_after_builder = defined $after_builder && ref $after_builder eq 'CODE';
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
            return $self->{$method} = shift if scalar @_;
            return $self->{$method} if exists $self->{$method};
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

1;
