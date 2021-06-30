package Class::Thingy::Level::2;
use warnings;
use strict;

sub import {
    my ($attrName, %args) = @_;
    my $className = caller;

    my $defaultsName = "${className}::MOODEFAULTS";

    my $constructorName = "${className}::new";
    my $constructorSub = sub {
        my $class = shift;
        my $self = bless({}, $class);
        my @defaults = do {
            no strict 'refs';
            return @{*{$defaultsName}};
        };
        foreach my $default (@defaults) {
            my ($attrName, $attrValue) = @_;
            if (ref $attrValue eq 'CODE') {
                $self->$attrName($self->$attrValue->());
            } else {
                $self->$attrName($attrValue);
            }
        }
        while (scalar @_ >= 2) {
            my $attrName = shift;
            my $attrValue = shift;
            $self->$attrName($attrValue);
        }
        return $self;
    };

    my $hasName      = "${className}::has";

    no strict 'refs';
    *{$hasName} = \&has;
    *{$constructorName} = $constructorSub;
    *{$defaultsName} = [];
}

sub has {
    my ($attrName, %args) = @_;
    my $className = caller;

    my $is = delete $args{is};
    if (!defined $is) {
        die("has: must pass is => 'rw'\n");
    }
    if ($is ne 'rw') {
        die("has: cannot pass is => '$is'\n");
    }

    my $default = delete $args{default};
    if (scalar keys %args) {
        my @keys = sort keys %args;
        die("has: parameters not supported: @keys\n");
    }

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
