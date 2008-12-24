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
	$self->_set_relatives_coordinates($self->{coordinates});
	return $self;
}

1;
