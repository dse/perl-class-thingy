package Class::Thingy::Util;
use warnings;
use strict;
use v5.10.0;

use base qw(Exporter);

our @EXPORT = qw();
our @EXPORT_OK = qw(debug);

sub debug {
    my @caller = caller(0);
    my $caller_class = $caller[0];
    my $caller_sub   = $caller[3];
    return unless eval {
        my $var_name = "${caller_class}::DEBUG";
        no strict qw(refs);
        ${$var_name};
    };
    printf STDERR ("%s::%s: %s: " . shift . "\n",
                   $caller_class, $caller_sub, ${^GLOBAL_PHASE}, @_);
}

1;
