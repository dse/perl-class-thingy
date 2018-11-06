package Class::Thingy::Public;
use warnings;
use strict;
use v5.10.0;

our $VERSION = '0.0';

our $DEBUG = 1;

use Carp;
use mro;

use base "Exporter";

our @EXPORT = qw(public);
our @EXPORT_OK = qw(public);

our @PACKAGES_USING_ME;
our $CTO_CLASS_NAME = "Class::Thingy::Object";

# This cannot be done at the BEGIN phase.  Imports are usually done at
# the BEGIN phase.
INIT {
    add_superclass_to_packages();
}

# We intercept import to keep track of classes that use us.
sub import {
    my $package = caller;
    print STDERR ("Class::Thingy::Public::import: ${^GLOBAL_PHASE}: calling \$package is $package\n") if $DEBUG;
    push(@PACKAGES_USING_ME, $package);

    # In case of any imports of Class::Thingy after the BEGIN phase
    # (typically runtime).
    if (grep { ${^GLOBAL_PHASE} eq $_ } qw(INIT RUN END DESTRUCT)) {
        add_superclass_to_packages();
    }

    # Go to the original import method.
    my $super_import = $package->can("SUPER::import");
    goto &$super_import if $super_import;
}

sub add_superclass_to_packages {
    # We add Class::Thingy::Object as a superclass of any packages
    # that don't have us listed as a superclass already.  We append it
    # so any "new" methods added afterwards get favored by the default
    # method resolution order.  If C::T::O is already in each
    # package's @ISA list, nothing is changed.
    foreach my $package (@PACKAGES_USING_ME) {
        my $isa_var_name = "${package}::ISA";
        no strict "refs";
        if (!grep { $_ eq $CTO_CLASS_NAME } @{$isa_var_name}) {
            print STDERR ("Class::Thingy::Public::add_superclass_to_packages: ${^GLOBAL_PHASE}: adding $CTO_CLASS_NAME to \@{$isa_var_name}\n") if $DEBUG;
            push(@{$isa_var_name}, $CTO_CLASS_NAME);
            require Class::Thingy::Object;
        }
    }
}

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
