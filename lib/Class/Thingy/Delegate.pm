package Class::Thingy::Delegate;
use warnings;
use strict;
use v5.10.0;

use base "Exporter";
our @EXPORT    = qw(delegate);
our @EXPORT_OK = qw(delegate);

sub delegate(*;@) {
    my ($method_name, %args) = @_;
    my $via = delete $args{via};
    $args{delegate} = $via if defined $via;
    @_ = ($method_name, %args);
    goto &Class::Thingy::public;
}

1;
