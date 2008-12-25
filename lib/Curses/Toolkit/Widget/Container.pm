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
# propagate to the children
sub _set_relatives_coordinates {
	my $self = shift;
	$self->SUPER::_set_relatives_coordinates(@_);
	# TODO : rework for n children
	my $coordinates = $self->_get_available_space();
	foreach my $child_widget ($self->get_children()) {
		$child_widget->_set_relatives_coordinates($coordinates);
	}
	return $self;
}


1;
