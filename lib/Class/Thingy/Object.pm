package Class::Thingy::Object;
use warnings;
use strict;
use v5.10.0;

use Carp;

sub new {
    my $class = shift;
    my $hash = (scalar @_ == 1 && ref $_[0] eq "HASH") ? shift : { @_ };
    my $self = bless($hash, $class);
    $self->init() if $self->can("init");
    return $self;
}

1;
