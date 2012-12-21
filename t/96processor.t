use strict;
use warnings;
use Test::More;
use MooX::Struct ();

ok not eval {
	"MooX::Struct::Processor"->new(flags => 1);
};

ok not eval {
	"MooX::Struct::Processor"->new(class_map => 1);
};

ok not eval {
	"MooX::Struct::Processor"->new->process(
		__PACKAGE__,
		Foo => [ -monkey => ['Albert'] ],
	);
	Foo();
};
like($@, qr{option '-monkey' unknown});

done_testing;
