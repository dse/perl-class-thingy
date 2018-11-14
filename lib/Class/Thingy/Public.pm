package Class::Thingy::Public;
use warnings;
use strict;
use v5.10.0;

# Features of Class::Tiny:
# - defines attributes via import arguments
#   - we export a method called public for creating attributes
#   - we call attributes "properties" instead
# - generates read-write accessors
#   - we do this
# - supports lazy attribute defaults
#   - in the pipeline
# - supports custom accessors
#   - eh?
# - superclass provides a standard new constructor
#   - sure, why not, we do it, base class is Class::Thingy::Object
# - new takes a hash reference or list of key/value pairs
#   - sure, why not, Class::Thingy::Object::new does this
# - new supports providing BUILDARGS to customize constructor options
#   - eh?
# - new calls BUILD for each class from parent to child
#   - useless feature imo
# - superclass provides a DESTROY method
#   - useless feature imo
# - DESTROY calls DEMOLISH for each class from child to parent
#   - useless feature imo

1;
