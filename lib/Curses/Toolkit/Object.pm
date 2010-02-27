use warnings;
use strict;

package Curses::Toolkit::Object;

# ABSTRACT: base class for objects

=head1 DESCRIPTION

Base class for objects

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
	my ($class) = shift;

	# TODO : use Exception;
	$class eq __PACKAGE__ and die "abstract class";
}

1;
