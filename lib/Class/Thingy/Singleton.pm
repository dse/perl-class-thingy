package Class::Thingy::Singleton;
use warnings;
use strict;
use v5.10.0;

our $DEBUG = 0;

use base qw(Exporter);

our @EXPORT = qw(singleton);
our @EXPORT_OK = qw(singleton);

sub singleton {
    my $class_name = caller;
    my $sub_name = "${class_name}::SINGLETON";
    my $var_name = "${class_name}::SINGLETON";
    my $sub = sub {
        no strict "refs";
        my $self = (${$var_name} //= $class_name->new);
        return $self;
    };
    no strict "refs";
    *{$sub_name} = $sub;
}

1;
