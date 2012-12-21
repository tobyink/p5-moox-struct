use strict;
use warnings;
use Test::More;

use MooX::Struct;

my $obj = MooX::Struct->new;
is($obj->TYPE, undef);
is_deeply([$obj->FIELDS], []);

done_testing;
