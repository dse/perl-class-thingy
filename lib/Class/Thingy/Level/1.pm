package Class::Thingy::Level::1;
use warnings;
use strict;

sub import {
    my ($attrName, %args) = @_;
    my $className = caller;

    my $constructorName = "${className}::new";
    my $constructorSub = sub {
        my $class = shift;
        my $self = bless({}, $class);
        while (scalar @_ >= 2) {
            my $attrName = shift;
            my $attrValue = shift;
            $self->$attrName($attrValue);
        }
        return $self;
    };

    my $hasName = "${className}::has";

    no strict 'refs';
    *{$hasName} = \&has;
    *{$constructorName} = $constructorSub;
}

sub has {
    my ($attrName, %args) = @_;
    my $className = caller;

    my $accessorName = "${className}::${attrName}";
    my $accessor = sub {
        my $self = shift;
        if (!scalar @_) {
            return $self->{$attrName};
        }
        my $value = shift;
        return $self->{$attrName} = $value;
    };

    no strict 'refs';
    *{$accessorName} = $accessor;
}

1;
