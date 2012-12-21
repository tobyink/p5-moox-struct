use strict;
use warnings;

use Test::More (
	$] < 5.010
		? (skip_all => 'need Perl 5.10')
		: ()
);

use 5.010;
use Test::More;
use MooX::Struct ();
use IO::Handle;

my $output;
open my $handle, '>', \$output;
my $proc = "MooX::Struct::Processor"->new(trace => 1, trace_handle => $handle);


$proc->process(
	__PACKAGE__,
	Something => ['$foo', announce_foo => sub { say shift->foo } ],
);
my $obj = new_ok Something(), [[1]];

is($output, <<"EXPECTED");
package @{[ Something() ]};
use Moo;
has foo => ('isa' => sub { "DUMMY" },'is' => 'ro');
sub announce_foo { ... }
sub FIELDS { ... }
sub TYPE { ... }
EXPECTED

$output = '';

BEGIN {
	package Local::Role;
	use Moo::Role;
	requires 'foo';
};

$proc->flags->{deparse} = 1;
$proc->process(
	__PACKAGE__,
	SomethingElse => [
		-class       => \'Something::Else',
		-isa         => [Something()],
		-with        => ['Local::Role'],
		announce_foo => sub { my $self = shift; print $self->foo, "\n" },
	],
);

$obj = new_ok SomethingElse(), [[1]];

like($output, qr{package Something::Else});
like($output, qr{with qw.Local::Role.});
like($output, qr{print \$self->foo});

done_testing;
