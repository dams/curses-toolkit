use warnings;
use strict;

package Curses::Toolkit::Widget::ScrollArea;

# ABSTRACT: a scrollable area

use parent qw(Curses::Toolkit::Widget::Bin);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
#    $self->{visibility_mode} = 'auto';
    $self->{scroll_x} = 0;
    $self->{scroll_y} = 0;
    return $self;
}

# # Returns the relative rectangle that a child widget can occupy. Overloads the
# # method from Curses::Toolkit::Widget::Container : we return the virtual space
# # of the scroll area, instead of the real coordinates.
# #
# # input  : none
# # output : a Curses::Toolkit::Object::Coordinates object

# sub _get_available_space {
#     my ($self) = @_;
# #    my $rc = $self->get_relatives_coordinates();
#     use Curses::Toolkit::Object::Coordinates;
#     return Curses::Toolkit::Object::Coordinates->new(
#         x1 => 0,   y1 => 0,
#         x2 => 300, y2 => 300,
#     );
# }

# rebuild the children coordinate, don't specify available space to children
sub _rebuild_children_coordinates {
    my ($self)          = @_;
    my ($child_widget)  = $self->get_children();
    defined $child_widget or return;

    # How much does the child widget want ? We don't specify a given size
    my $child_space = $child_widget->get_desired_space();

    # scroll the space accordingly
    $child_space->set(
        x1 => $child_space->get_x1() + $self->{scroll_x}, y1 => $child_space->get_y1() + $self->{scroll_y},
        x2 => $child_space->get_x2() + $self->{scroll_x}, y2 => $child_space->get_y2() + $self->{scroll_y},
    );

    # A Scroll Area always grant the desired space
    $child_widget->_set_relatives_coordinates($child_space);
    $child_widget->can('_rebuild_children_coordinates')
        and $child_widget->_rebuild_children_coordinates();
    return $self;
}


=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The ScrollArea desires all the space available, so it returns the available space

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {

    my ( $self, $available_space ) = @_;

    if (!defined $available_space) {
        my ($child_widget)  = $self->get_children();
        defined $child_widget
          or return Curses::Toolkit::Object::Coordinates->new_zero();
        return $child_widget->get_desired_space();
    }

    my $desired_space = $available_space->clone();
    return $desired_space;
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
    my ( $self, $available_space ) = @_;

    my ($child_widget)  = $self->get_children();
    defined $child_widget
      or return Curses::Toolkit::Object::Coordinates->new_zero();
    return $child_widget->get_minimum_space(defined $available_space ? $available_space : ());
}

1;
