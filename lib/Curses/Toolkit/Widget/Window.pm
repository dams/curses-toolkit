package Curses::Toolkit::Widget::Window;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Bin);

=head1 NAME

Curses::Toolkit::Widget::Window - a window

=head1 DESCRIPTION

This is a window widget

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Window

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	# set window stack by default
	$self->set_property('window', 'stack', -1);
	return $self;
}

=head2 set_coordinates

Set the coordinates (see L<Curses::Toolkit::Object::Coordinates> )

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
  output : the window

=cut

sub set_coordinates {
	my $self = shift;
	use Curses::Toolkit::Object::Coordinates;
	$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
#  	my $rc = $self->{coordinates}->clone();
# 	$rc->set( x1 => 0, y1 => 0,
# 			  x2 => $rc->width(), y2 => $rc->height(),
# 			);
	$self->_set_relatives_coordinates($self->{coordinates});
	# needs to take care of rebuilding coordinates from top to bottom
	$self->rebuild_all_coordinates();
	return $self;
}

=head2 set_root_window

Sets the root window ( the root toolkit object) to which this window is added 

  input  : the root toolkit object (Curses::Toolkit)
  output : the window

=cut

sub set_root_window {
	my ($self, $root_window) = @_;
	$self->{root_window} = $root_window;
	return $self;
}

=head2 get_root_window

Get the root window

  input  : none
  output : the root toolkit object (Curses::Toolkit)

=cut

sub get_root_window {
	my ($self) = @_;
	return $self->{root_window};
}

1;
