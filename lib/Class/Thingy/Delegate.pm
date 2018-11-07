package Class::Thingy::Delegate;
use warnings;
use strict;
use v5.10.0;

use base "Exporter";
our @EXPORT    = qw(delegate);
our @EXPORT_OK = qw(delegate);

sub delegate(*;@) {
    my ($method_name, %args) = @_;
    my $class_name = caller;
    my $sub_name = "${class_name}::${method_name}";
    my $via = $args{via};
    $method_name = $args{method} // $method_name;
    if (!defined $via) {
        die("Must specify via when using delegate.\n");
    }
    my $sub = sub {
        my $self = shift;
        return $self->$via->$method_name(@_);
    };
    no strict "refs";
    *{$sub_name} = $sub;
}

1;
