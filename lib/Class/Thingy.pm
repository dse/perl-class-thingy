package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use lib "$ENV{HOME}/git/dse.d/perl-class-thingy/lib";

use base "Class::Thingy::Public";

our @EXPORT    = qw(public);
our @EXPORT_OK = qw(public);

use Class::Thingy::Util qw(debug);

sub public (*;@) {
    goto &Class::Thingy::Public::public;
}

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

    debug("added %s to \@PACKAGES_USING_ME", $package);

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
            push(@{$isa_var_name}, $CTO_CLASS_NAME);

            debug("added %s to \@%s", $CTO_CLASS_NAME, $isa_var_name);

            require Class::Thingy::Object;
        }
    }
}

1;
