use warnings;
use strict;

package Curses::Toolkit::Widget::Container;

# ABSTRACT: a container widget

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(:all);


=head1 DESCRIPTION

This widget can contain 0 or more other widgets.

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Container

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    use Tie::Array::Iterable;
    my @children = ();

    $self->{children} = Tie::Array::Iterable->new(@children);

    return $self;
}

=head1 METHODS

=head2 render

Default rendering method for the widget. All render() method should call draw()

  input  : curses_handler
  output : the widget

=cut

sub render {
    my ($self) = @_;
    $self->blank();
    foreach my $child ( $self->get_children() ) {
        $child->render();
    }
    $self->draw();
    return;
}

# default method for blanking
sub blank {
    my ($self) = @_;
    my $theme  = $self->get_theme();
    my $c      = $self->get_coordinates();
    my $bc     = $self->_get_available_space() + {
        x1 => $c->get_x1(), y1 => $c->get_y1(),
        x2 => $c->get_x1(), y2 => $c->get_y1(),
    };
    $theme->draw_blank($bc);
    return $self;
}

=head2 get_children

Returns the list of children of the widget

  input : none
  output : ARRAY of Curses::Toolkit::Widget

=cut

sub get_children {
    my ($self) = @_;
    return @{ $self->{children} };
}

sub _add_child {
    my $self = shift;
    return $self->_add_child_at_end(@_);
}

sub _add_child_at_end {
    my ( $self, $child_widget ) = @_;
    push @{ $self->{children} }, $child_widget;
    my $iterator = $self->{children}->forward_from( @{ $self->{children} } - 1 );
    $child_widget->_set_iterator($iterator);
    return $self;
}

sub _add_child_at_beginning {
    my ( $self, $child_widget ) = @_;
    unshift @{ $self->{children} }, $child_widget;
    my $iterator = $self->{children}->forward_from(0);
    $child_widget->_set_iterator($iterator);
    return $self;
}

# overload Widget's method : not sure why
sub _set_relatives_coordinates {
    my $self = shift;
    $self->SUPER::_set_relatives_coordinates(@_);
    return $self;
}

# Returns the relative rectangle that a child widget can occupy.
# This is the default method, returns the whole widget space.
#
# input  : none
# output : a Curses::Toolkit::Object::Coordinates object

sub _get_available_space {
    my ($self) = @_;
    my $rc = $self->get_relatives_coordinates();
    use Curses::Toolkit::Object::Coordinates;
    return Curses::Toolkit::Object::Coordinates->new(
        x1 => 0,            y1 => 0,
        x2 => $rc->width(), y2 => $rc->height(),
    );
}

1;
