package MooX::Struct;

use 5.008;
use strict;
use warnings;
use utf8;

BEGIN {
	$MooX::Struct::AUTHORITY = 'cpan:TOBYINK';
	$MooX::Struct::VERSION   = '0.001';
}

use Moo             1.000000;
use Data::OptList   0         qw();
use Sub::Install    0         qw();
use Scalar::Does    0         qw( does );
use Object::ID      0         qw( object_id );

my $counter = 0;
my $generate_class_name = sub
{
	return sprintf('%s::__ANON__::%04d', __PACKAGE__, ++$counter);
};

sub import
{
	my $caller = caller;
	my $me     = shift;
	my @args   = @{ Data::OptList::mkopt(\@_) };
	
	foreach my $arg (@args)
	{
		my ($subname, $class) = @$arg;
		$class = [] unless defined $class;
		
		Sub::Install::install_sub {
			into   => $caller,
			as     => $subname,
			code   => sub ()
			{
				if (ref $class) # inflate!
				{
					my @attrs = @{ Data::OptList::mkopt($class) };
					$class = $generate_class_name->();
					Moo->_set_superclasses($class, __PACKAGE__);
					Moo->_maybe_reset_handlemoose($class);
					foreach my $attr (@attrs)
					{
						my ($name, $val) = @$attr;
						if (does $val, 'CODE')
						{
							Sub::Install::install_sub {
								into   => $class,
								as     => $name,
								code   => $val,
							};
						}
						else
						{
							my %spec = (
								is => 'ro',
								( does($val, 'ARRAY')
									? @$val
									: ( does($val,'HASH') ? %$val : () )
								),
							);
							Moo->_constructor_maker_for($class)
								->register_attribute_specs($name, \%spec);
							Moo->_accessor_maker_for($class)
								->generate_method($class, $name, \%spec);
							Moo->_maybe_reset_handlemoose($class);
						}
					}
				}
				return $class;
			},
		};
	}
}

no Moo;

1;

__END__

=head1 NAME

MooX::Struct - make simple lightweight record-like structures that make sounds like cows

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooX-Struct>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

