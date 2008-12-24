package Curses::Toolkit::Widget::Border;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Bin);

=head1 NAME

Curses::Toolkit::Widget::Border - a border widget

=head1 DESCRIPTION

This widget consists of a border, and a child widget in that border

This widget can contain 0 or 1 other widget.

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Border

=cut

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	$theme->draw_hline($c->x1(), $c->y1(), $c->width());
	$theme->draw_hline($c->x1(), $c->y2(), $c->width());
	$theme->draw_vline($c->x1(), $c->y1(), $c->height());
	$theme->draw_vline($c->x2(), $c->y1(), $c->height());
	$theme->draw_corner_ul($c->x1(), $c->y1());
	$theme->draw_corner_ll($c->x1(), $c->y2());
	$theme->draw_corner_ur($c->x2(), $c->y1());
	$theme->draw_corner_lr($c->x2(), $c->y2());
}

# Returns the relative rectangle that a child widget can occupy.
# This returns the current widget space, shrinked by one (the border size)
#
# input : none
# output : a Curses::Toolkit::Object::Coordinates object

sub _get_available_space {
	my ($self) = @_;
	my $rc = $self->get_relative_coordinates();
	my $coordinates = $rc-1;
	return $coordinates;
}

1;
