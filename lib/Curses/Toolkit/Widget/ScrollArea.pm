use warnings;
use strict;

package Curses::Toolkit::Widget::ScrollArea;

# ABSTRACT: a scrollable area

use parent qw(Curses::Toolkit::Widget::Bin);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

use Curses::Toolkit::Widget::VScrollBar;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    my %params = validate(
        @_,
        {   scrollbars_mode => { type => SCALAR, default => 'always' },
        }
    );
#    $self->{visibility_mode} = 'auto';
    $self->{scroll_x} = 0;
    $self->{scroll_y} = 0;
    $self->set_scrollbars_mode($params{scrollbars_mode});
    return $self;
}

sub set_scrollbars_mode {
    my ($self, $mode) = @_;
    if ($mode eq 'always') {
        $self->{scrollbars_mode} = $mode;
        $self->{v_scrollbar} = Curses::Toolkit::Widget::VScrollBar->new();
#        $self->{h_scrollbar} = Curses::Toolkit::Widget::HScrollBar->new();
    } else {
        die "scrollbar mode '" . $mode . "' is not supported";
    }
}

# Returns the relative rectangle that a child widget can occupy. Overloads the
# method from Curses::Toolkit::Widget::Container : we return the widget space,
# minus the potential scrollbars

# input  : none
# output : a Curses::Toolkit::Object::Coordinates object

sub _get_available_space {
    my ($self) = @_;
    my $rc = $self->get_relatives_coordinates();
    if ($self->{scrollbars_mode} eq 'always') {
        $rc->get_x2() > $rc->get_x1() &&
        $rc->get_y2() > $rc->get_y1()
          or return Curses::Toolkit::Object::Coordinates->new_zero();
        return Curses::Toolkit::Object::Coordinates->new(
            x1 => $rc->get_x1,          y1 => $rc->get_x1,
            x2 => $rc->get_x2() - 1,    y2 => $rc->get_y2() - 1,
        );
    } else {
        die "scrollbar mode '" . $self->{scrollbars_mode} . "' is not supported";
    }
}

sub draw {
    my ($self) = @_;
    if ($self->{scrollbars_mode} eq 'always') {
        if ( defined ($self->{v_scrollbar}) ) {

            # XXX FIXME This is a Hack

#            my $c = $self->get_coordinates();
            my $c = $self->get_visible_shape;
            my $theme = $self->get_theme();
#            $theme->draw_string( $c->get_x1(), $c->get_y1(), 'PLOP');


            $self->{v_scrollbar}->{coordinates} = Curses::Toolkit::Object::Coordinates->new(
                x1 => $c->get_x2()-1, y1 => $c->get_y1(),
                x2 => $c->get_x2(), y2 => $c->get_y2(),
            );
#            $self->{v_scrollbar}->set_theme_name($self->get_theme_name);
            $self->{v_scrollbar}->{theme_name} = $self->get_theme_name;
            $self->{v_scrollbar}->{theme} = $self->get_theme;
            $self->{v_scrollbar}->draw();
        }
    } else {
        die "scrollbar mode '" . $self->{scrollbars_mode} . "' is not supported";
    }
    
    return;
}


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

# overload the visible shape to take scrollbars in account
sub get_visible_shape_for_children {
    my ($self) = @_;
    my $shape = $self->get_visible_shape();
    if ($shape->width > 0) {
        $shape->set( x2 => $shape->get_x2() - 1);
    }
    return $shape;
}

#sub get_visible_shape {
#    my ($self) = @_;
#    my $shape = $self->SUPER::get_visible_shape();
#    $shape->set( x2 => $shape->get_x2()-1 );
#    return $shape;
#}


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

sub get_child_occupied_space {
    my ($self) = @_;
    my $child_widget = $self->child;
    defined $child_widget
      or return Curses::Toolkit::Object::Coordinates->new_zero();
    return $child_widget->relatives_coordinates()->clone;
}

1;
