package Class::Thingy::Level::0::Test::B;
use warnings;
use strict;

use Class::Thingy::Level::0;

has 'attr' => (is => 'rw', default => 15);

sub getAttr {
    my ($self) = @_;
    return $self->attr();
}
sub setAttr {
    my ($self, $value) = @_;
    return $self->attr($value);
}

1;
