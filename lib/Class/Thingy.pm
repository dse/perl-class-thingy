package Class::Thingy;
use warnings;
use strict;
use v5.10.0;

use lib "$ENV{HOME}/git/dse.d/perl-class-thingy/lib";

use base "Class::Thingy::Public";

our @EXPORT    = qw(public);
our @EXPORT_OK = qw(public);

sub public (*;@) {
    goto &Class::Thingy::Public::public;
}

1;
