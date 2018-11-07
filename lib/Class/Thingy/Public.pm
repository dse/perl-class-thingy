package Class::Thingy::Public;
use warnings;
use strict;
use v5.10.0;

our $VERSION = '0.0';

our $DEBUG = 0;

use Carp;
use mro;

use base "Exporter";

our @EXPORT = qw(public);
our @EXPORT_OK = qw(public);

sub public (*;@) {
    my ($method_name, %args) = @_;
    my $class_name = caller;
    my $sub_name = "${class_name}::${method_name}";
    my $defaults_name      = "${class_name}::CLASS_THINGY_DEFAULTS";
    my $sub_defaults_name  = "${class_name}::CLASS_THINGY_SUB_DEFAULTS";
    my $lazy_defaults_name = "${class_name}::CLASS_THINGY_LAZY_DEFAULTS";
    my $sub = sub {
        my $self = shift;
        return $self->{$method_name} = shift if scalar @_;
        return $self->{$method_name} if exists $self->{$method_name};
        my @mro = @{ mro::get_linear_isa(ref $self) };
        foreach my $mro (@mro) {
            my $mro_lazy_defaults_name = "${mro}::CLASS_THINGY_LAZY_DEFAULTS";
            no strict "refs";
            if (exists ${$mro_lazy_defaults_name}{$method_name}) {
                return $self->{$method_name} = ${$mro_lazy_defaults_name}{$method_name}->();
            }
        }
        return;
    };
    my $count = 0;
    $count += 1 if exists $args{default};
    $count += 1 if exists $args{sub_default};
    $count += 1 if exists $args{lazy_default};
    if ($count > 1) {
        carp "Cannot specify more than one type of default for $class_name property $method_name.";
    }
    if (exists $args{default}) {
        no strict "refs";
        ${$defaults_name}{$method_name} = $args{default};

        print STDERR ("Class::Thingy::Public::public: ${^GLOBAL_PHASE}: \${$defaults_name}{$method_name} = $args{default}\n") if $DEBUG;

    } elsif (exists $args{sub_default}) {
        if (ref $args{sub_default} ne "CODE") {
            carp "Cannot specify other than a subroutine reference for $class_name property $method_name as a sub_default.";
        }
        no strict "refs";
        ${$sub_defaults_name}{$method_name} = $args{sub_default};

        print STDERR ("Class::Thingy::Public::public: ${^GLOBAL_PHASE}: \${$sub_defaults_name}{$method_name} = $args{sub_default}\n") if $DEBUG;

    } elsif (exists $args{lazy_default}) {
        if (ref $args{lazy_default} ne "CODE") {
            carp "Cannot specify other than a subroutine reference for $class_name property $method_name as a lazy_default.";
        }
        no strict "refs";
        ${$lazy_defaults_name}{$method_name} = $args{lazy_default};

        print STDERR ("Class::Thingy::Public::public: ${^GLOBAL_PHASE}: \${$lazy_defaults_name}{$method_name} = $args{lazy_default}\n") if $DEBUG;

    }
    no strict "refs";
    *{$sub_name} = $sub;

    print STDERR ("Class::Thingy::Public::public: ${^GLOBAL_PHASE}: *{$sub_name} = sub { ... }\n") if $DEBUG;
}

# Features of Class::Tiny::
# - defines attributes via import arguments
#   - we export a method called public for creating attributes
#   - we call attributes "properties" instead
# - generates read-write accessors
#   - we do this
# - supports lazy attribute defaults
#   - in the pipeline
# - supports custom accessors
#   - eh?
# - superclass provides a standard new constructor
#   - sure, why not, we do it, base class is Class::Thingy::Object
# - new takes a hash reference or list of key/value pairs
#   - sure, why not, Class::Thingy::Object::new does this
# - new supports providing BUILDARGS to customize constructor options
#   - eh?
# - new calls BUILD for each class from parent to child
#   - useless feature imo
# - superclass provides a DESTROY method
#   - useless feature imo
# - DESTROY calls DEMOLISH for each class from child to parent
#   - useless feature imo

1;
