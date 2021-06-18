package Class::Thingy::Level::0;
use warnings;
use strict;

=head1 NAME

Class::Thingy::Level::0 - the dumbest possible object framework

=head1 SYNOPSIS

    package My::Object;
    use Class::Thingy::Level::0;
    has 'attribute';
    ...

    my $o = My::Object->new();
    ...
    my $savedValue = $o->attribute();
    ...
    $o->attribute($newValue);

=head1 DESCRIPTION

C<Class::Thingy::Level::0> creates a constructor called C<new> for
you.

Use C<has> to add object attributes.

That's it.

=head1 CAVEATS

=over 4

=item *

There is no mechanism to specify default values.

=item *

Additional arguments passed to the constructor are silently ignored.

The following code example creates a new object without a value set
for the C<attribute>:

    my $o = My::Object->new(attribute => 3);
    ...

=item *

Additional arguments passed to C<has> are silently ignored.

The following code example also creates a new object without a value
set for the C<attribute>:

    package My::Object;
    use Class::Thingy::Level::0;
    has 'attribute' => (is => 'rw', default => 3);
    ...

    my $o = My::Object->new();
    ...

=back

=cut

sub import {
    my ($attrName, %args) = @_;
    my $className = caller;

    my $constructorName = "${className}::new";
    my $constructorSub = sub {
        my $class = shift;
        my $self = bless({}, $class);
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
