package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use base "Exporter";

our @EXPORT = qw(public);

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
    push(@PACKAGES_USING_ME, $package);

    # In case of any runtime imports of Class::Thingy.  We don't need
    # to check ${^GLOBAL_PHASE} because add_superclass_to_packages is
    # idempotent.
    add_superclass_to_packages();

    my $super_import = $package->can("SUPER::import");
    goto &$super_import if $super_import;
}

sub add_superclass_to_packages {
    # We add Class::Thingy::Object as a superclass of any packages
    # that don't have us listed as a superclass already.  We append it
    # so any "new" methods added afterwards get favored by the default
    # method resolution order.
    foreach my $package (@PACKAGES_USING_ME) {
        no strict "refs";
        my $isa_var_name = "${package}::ISA";
        if (!grep { $_ eq $CTO_CLASS_NAME } @{$isa_var_name}) {
            push(@{$isa_var_name}, $CTO_CLASS_NAME);
            require Class::Thingy::Object;
        }
    }
}

sub public (*;@) {
    my ($method_name, %args) = @_;
    my $class_name = caller;
    my $sub_name = "${class_name}::${method_name}";
    my $sub = sub {
        my $self = shift;
        return $self->{$method_name} = shift if scalar @_;
        return $self->{$method_name};
    };
    no strict "refs";
    *{$sub_name} = $sub;
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
