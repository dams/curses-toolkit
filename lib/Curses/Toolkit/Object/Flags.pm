use warnings;
use strict;

package Curses::Toolkit::Object::Flags;

use parent qw(Curses::Toolkit::Object);

=head1 NAME

Curses::Toolkit::Object::Flags - simple collection of flags

=head1 DESCRIPTION

Trivial class to hold widgets flags.
The list of flags is :

  focused  : BOOLEAN
  selected : BOOLEAN
  clicked  : BOOLEAN

=head1 CONSTRUCTOR

=head2 new

  input  : none
  output : a Curses::Toolkit::Object::Flags object

=cut

sub new {
	my $class = shift;
	my $self = bless { focused  => 0,
				 selected => 0,
				 clicked  => 0,
			   }, $class;
	return $self;
}

1;
