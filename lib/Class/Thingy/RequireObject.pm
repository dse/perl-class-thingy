package Class::Thingy::RequireObject;
use warnings;
use strict;
use v5.10.0;

our $DEBUG = 1;

use base qw(Exporter);

our @EXPORT = qw(require_object);
our @EXPORT_OK = qw(require_object);

sub require_object {
    my $class_name = caller;
    my $sub_name = "${class_name}::REQUIRE_OBJECT";
    my $var_name = "${class_name}::SINGLETON";
    my $sub = sub {
        my $self = shift;
        if (!ref $self) {
            no strict "refs";
            $self = (${$var_name} //= $class_name->new);
        }
        return $self;
    };
    no strict "refs";
    *{$sub_name} = $sub;
}

1;
