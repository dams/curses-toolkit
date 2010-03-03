use warnings;
use strict;

package Curses::Toolkit::Widget::HPaned;

# ABSTRACT: a container with two panes arranged horizontally

use parent qw(Curses::Toolkit::Widget::Paned);

use Params::Validate qw(:all);

=head1 Appearence

With a border

  +-----------------+
  |                 |
  |   Widget 1      |
  |                 |
  +-----------------+
  |                 |
  |   Widget 2      |
  |                 |
  +-----------------+

=head1 DESCRIPTION

This widget contain 2 widgets. The children are packed horizontally.

=cut

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::HPaned

=cut

sub _p1 {
    my ( $self, $c ) = @_;
    return $c->get_x1();
}

sub _p2 {
    my ( $self, $c ) = @_;
    return $c->get_y2();
}

sub _p3 {
    my ( $self, $c ) = @_;
    return $c->width();
}

sub _p4 {
    my ( $self, $c, $gp ) = @_;
    return ( x2 => $c->get_x1() + $gp );
}

sub _p5 {
    my ( $self, $c, $gp, $gw ) = @_;
    return ( x1 => $c->get_x1() + $gp + $gw );
}

sub _p6 {
    my ( $self, $gp, $gw ) = @_;
    return ( x2 => $gp + $gw, y2 => 1 );
}

sub _p7 {
    my ( $self, $theme, $c, $i, $gp, $attr ) = @_;
    $theme->draw_vline( $c->get_x1() + $gp + $i, $c->get_y1(), $c->height(), $attr );
    return;
}

sub _p8 {
    my ( $self, $c, $gp, $gw ) = @_;
    return ( x2 => $c->get_x1() + $gp + $gw );
}

sub _p9 {
    my ( $self, $c ) = @_;
    return ( y2 => $c->get_y2() );
}

sub _p10 {
    my ( $self, $c ) = @_;
    return ( x1 => $c->get_x1() );
}

sub _p11 {
    my ( $self, $c1, $c2 ) = @_;
    return ( x2 => $c1->get_x1() + $c1->width() + $c2->width() );
}

sub _p12 {
    my ( $self, $c ) = @_;
    return ( y2 => $c->get_y1() + 1 );
}

sub _p13 {
    my ( $self, $c1, $c2 ) = @_;
    use List::Util qw(max);
    return ( y2 => max( $c1->get_y2(), $c2->get_y2() ) );
}

=head1 METHODS

=head2 add1

Add a widget in the left box

  input  : the child widget
  output : the current widget (not the child widget)

=head2 add2

Add a widget in the right box

  input  : the child widget
  output : the current widget (not the child widget)

=head2 set_gutter_position

Set the position of the gutter from the left

  input  : the position (an integer)
  output : the current widget (not the child widget)

=head2 get_gutter_position

Return the position of the gutter from the left

  input  : none
  output : the current gutter position

=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

1;
