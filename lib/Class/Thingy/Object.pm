package Class::Thingy::Object;
use warnings;
use strict;
use v5.10.0;

our $VERSION = '0.0';

use Carp;
use mro;

sub new {
    my $class = shift;

    # first UNIVERSAL, then all the way to the class itself
    my $mro = mro::get_linear_isa($class);
    my @mro = reverse @$mro;

    # build this object's hash from defaults
    my %hash;
    foreach my $mro (@mro) {
        my $hash_name = "${mro}::CLASS_THINGY_DEFAULTS";
        my %addhash;
        no strict "refs";
        %hash = (%hash, %{$hash_name});
    }

    # then override with anything passed to the constructor
    if (scalar @_ == 1 && ref $_[0] eq "HASH") {
        my %addhash = %{$_[0]};
        %hash = (%hash, %addhash);
    } elsif (scalar @_ % 2 != 0) {
        carp "${class}->new() called with odd number of arguments";
    } else {
        %hash = (%hash, @_);
    }

    # instantiate
    my $self = bless(\%hash, $class);
    $self->init() if $self->can("init");
    return $self;
}

1;
