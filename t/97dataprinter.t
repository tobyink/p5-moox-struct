use strict;
use warnings;

use if !eval{ require Data::Printer },
	'Test::More', skip_all => 'need Data::Printer';

use Test::More;

use Data::Printer colored => 0;
use MooX::Struct Something => [qw( $foo $bar )];

my $obj = Something->new(foo => 1, bar => 2);
my $str = p $obj;

is($str, 'Something[ 1, 2 ]');

done_testing;
