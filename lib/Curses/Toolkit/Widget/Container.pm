package Curses::Toolkit::Widget::Container;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::Container - a container widget

=head1 DESCRIPTION

This widget can contain 0 or more other widgets.

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Container

=cut

=head1 METHODS

=head2 add_widget

Add a widget

  input  : the child widget
  output : the current widget (not the child widget)

=cut

sub add_widget {
	my $self = shift;
	my ($child_widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' } );
	push @{$self->{children}}, $child_widget;
	$child_widget->_set_parent($self);
	my $coordinates = $self->_get_available_space();
	$child_widget->_set_relatives_coordinates($coordinates);
	return $self;
}

# overload Widget's method : after setting relatives coordinates, needs to
# propagate to the children.
# This is the default behaviour : "pack" all the widgets vertically, with full
# horizontal width.
sub _set_relatives_coordinates {
	my $self = shift;
	$self->SUPER::_set_relatives_coordinates(@_);
	my $available_space = $self->_get_available_space();
	foreach my $child_widget ($self->get_children()) {
		# Given the available space, how much does the widget want ?
		my $child_space = $child_widget->get_desired_space($available_space->clone());
		# Make sure it's not bigger than what is available
		$child_space->restrict_to($available_space);
		# Force the child space to be as large as the available space
		$child_space->set(x1 => $available_space->x1(), x2 => $available_space->x2() );
		# At the end, we grant it this space
		$child_widget->_set_relatives_coordinates($child_space);
		# now diminish the available space
		$available_space = $available_space->add( { y1 => $child_space->y2() + 1 } );
	}
	return $self;
}

# Returns the relative rectangle that a child widget can occupy.
# This is the default method, returns the whole widget space.
#
# input : none
# output : a Curses::Toolkit::Object::Coordinates object

sub _get_available_space {
	my ($self) = @_;
	my $rc = $self->get_relatives_coordinates();
	use Curses::Toolkit::Object::Coordinates;
	return Curses::Toolkit::Object::Coordinates->new(
		x1 => 0, y1 => 0,
        x2 => $rc->width()-1, y2 => $rc->height()-1,
	);
}

1;
