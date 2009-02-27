package Curses::Toolkit::Widget::VBox;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::VBox - a vertical box widget

=head1 DESCRIPTION

This widget can contain 0 or more widgets. The children are packed vertically.

=cut

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::VBox

=cut

=head1 METHODS

=head2 pack_start

Add a widget in the vertical box, at the start of the box. You can call
pack_start multiple time to add more widgets.

  input  : the child widget
           optionally, a hash containing options
  output : the current widget (not the child widget)

The hash containing options can contain :

  expand : TRUE if the new child is to be given extra space allocated to box.
  The extra space will be divided evenly between all children of box that use
  this option

  fill : TRUE if space given to child by the expand option is actually
  allocated to child, rather than just padding it. This parameter has no effect
  if expand is set to FALSE. A child is always allocated the full height of a
  GtkHBox and the full width of a GtkVBox. This option affects the other
  dimension

  padding : extra space in pixels to put between this child and its neighbors,
  over and above the global amount specified by "spacing" property. If child is
  a widget at one of the reference ends of box, then padding pixels are also
  put between child and the reference edge of box

=cut

sub pack_start {
	my $self = shift;
    my ($child_widget, $options) = validate( @_,
								   {
									{ isa => 'Curses::Toolkit::Widget' },
									{ type => HASHREF, default => {} },
								   }
								 );
	my %options = validate( $options, { expand  => { type => BOOLEAN, default => 0, can => [ 0, 1] },
										fill    => { type => BOOLEAN, default => 0, can => [ 0, 1] },
										padding => { type => INTEGER, default => 0, regex => qr/^\d+$/ },
									  }
						  );
	$self->_add_child($child_widget);
	$child_widget->set_property(packing => \%options);
	return $self;
}

# overload _add_child from Container to pack at start

sub _add_child {
	my ($self, $child) = @_;
	unshift @{$self->{children}}, $child_widget;
	return;
}

sub _rebuild_children_coordinates {
	my ($self) = @_;
	my $available_space = $self->_get_available_space();
	my @child_widgets = $self->get_children();

	# Given the available space, how much does the child widget want ?
	my $child_space = $child_widget->get_desired_space($available_space->clone());
	# Make sure it's not bigger than what is available
	$child_space->restrict_to($available_space);
# 		# Force the child space to be as large as the available space
# 		$child_space->set(x1 => $available_space->x1(), x2 => $available_space->x2() );
	# At the end, we grant it this space
	$child_widget->_set_relatives_coordinates($child_space);
	$child_widget->can('_rebuild_children_coordinates') and
	  $child_widget->_rebuild_children_coordinates();
	# now diminish the available space
	$available_space->add( { y1 => $child_space->y2() + 1 } );
	return $self;
}

=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The VBox desires all the space available, so it returns the available space

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my ($self, $available_space) = @_;
	my $desired_space = $available_space->clone();
	return $desired_space;
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my ($self, $available_space) = @_;
	my $desired_space = $available_space->clone();
	return $desired_space;
}

1;
