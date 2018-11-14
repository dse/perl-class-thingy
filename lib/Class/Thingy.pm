package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use base 'Exporter';
our @EXPORT    = qw(public);
our @EXPORT_OK = qw(public);

use mro;

use constant CTO => 'Class::Thingy::Object';

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
    }

    if (defined $args{delegate}) {
        my $delegate = $args{delegate};
        my $method = $args{method} // $method;
        $sub = sub {
            my $self = shift;
            return $self->$delegate->$method(@_);
        };
    } elsif (defined $args{builder} && ref $args{builder} eq 'CODE') {
        my $builder = $args{builder};
        $sub = sub {
            my $self = shift;
            return $self->{$method} = shift if scalar @_;
            return $self->{$method} if exists $self->{$method};
            return $self->{$method} = $self->$builder();
        };
    } elsif (defined $args{default}) {
        my $default = $args{default};
        $sub = sub {
            my $self = shift;
            return $self->{$method} = shift if scalar @_;
            return $self->{$method} if exists $self->{$method};
            return $self->{$method} = $default;
        };
    } else {
        $sub = sub {
            my $self = shift;
            return $self->{$method} = shift if scalar @_;
            return $self->{$method} if exists $self->{$method};
            return;
        };
    }
    no strict 'refs';
    *{$sub_name} = $sub;
}

1;
