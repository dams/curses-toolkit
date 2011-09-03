use warnings;
use strict;

package Curses::Toolkit::Widget::ScrollArea;

# ABSTRACT: a scrollable area

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

use Curses::Toolkit::Widget::VScrollBar;
use Curses::Toolkit::Widget::HScrollBar;

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
    $self->{_main_child} = undef;
    $self->set_scrollbars_mode($params{scrollbars_mode});
    return $self;
}

sub set_scrollbars_mode {
    my ($self, $mode) = @_;
    if ($mode eq 'always') {
        $self->{scrollbars_mode} = $mode;
        $self->{v_scrollbar} = Curses::Toolkit::Widget::VScrollBar->new()->set_scroll_area($self)
          ->set_name($self . '_vscrollbar');

        # A bit hackish (especially the setting of iterator to undef. I should
        # stop using iterators anyway
#        $self->_add_child_at_end($self->{v_scrollbar});
        $self->_add_child_at_beginning($self->{v_scrollbar});
        $self->{v_scrollbar}->_set_parent($self);
        $self->{v_scrollbar}->_set_iterator(undef);

        # because it's a container, needs to take care of rebuilding coordinates
        # from top to bottom
        $self->rebuild_all_coordinates();
        # $self->{h_scrollbar} = Curses::Toolkit::Widget::HScrollBar->new()->set_scroll_area($self);
    } else {
        die "scrollbar mode '" . $mode . "' is not supported";
    }
}

# overload add_widget to add it always as first child
sub add_widget {
    my $self = shift;
    my ($child_widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' } );
    defined $self->{_main_child}
        and die 'there is already a child widget';
    # scrollbars children are always the firsts, so that widget ordering (for
    # events for instance), find the scrollbar before the real child
    $self->_add_child_at_end($child_widget);
    $child_widget->_set_parent($self);
    $self->{_main_child} = $child_widget;

    # because it's a Container, needs to take care of rebuilding coordinates
    # from top to bottom
    $self->rebuild_all_coordinates();
    return $self;
}

sub scroll {
    my ($self, %params) = @_;
#    $self->{scroll_y} += 5;
    defined $params{x}
      and $self->{scroll_x} += $params{x};
    defined $params{y}
      and $self->{scroll_y} += $params{y};
    $self->rebuild_all_coordinates();
    $self->needs_redraw;
    return $self;
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

        # if ( defined ($self->{h_scrollbar}) ) {

        #     my $c = $self->get_visible_shape;

        #     # XXX FIXME This is a Hack
        #     $self->{h_scrollbar}->{coordinates} = Curses::Toolkit::Object::Coordinates->new(
        #         x1 => $c->get_x1(), y1 => $c->get_y2()-1,
        #         x2 => $c->get_x2()  - ( defined($self->{v_scrollbar}) ? 1 : 0), y2 => $c->get_y2(),
        #     );

        #     # XXX FIXME This is a Hack
        #     $self->{h_scrollbar}->{theme_name} = $self->get_theme_name;
        #     $self->{h_scrollbar}->{theme} = $self->get_theme;
        #     $self->{h_scrollbar}->draw();
        # }
    } else {
        die "scrollbar mode '" . $self->{scrollbars_mode} . "' is not supported";
    }
    
    return;
}


# rebuild the children coordinate, don't specify available space to children
sub _rebuild_children_coordinates {
    my ($self)          = @_;

    my $count = 0;
    defined $self->{v_scrollbar}
      and $count++;
    defined $self->{h_scrollbar}
      and $count++;
    
    my @children  = $self->get_children();
    @children > $count
      or return; # there were no main child

    # main child is always the last, so that widget ordering (for events for
    # instance), find the scrollbar before the real child
    my $child_widget = $children[-1];
    defined $child_widget or return;

    # How much does the child widget want ? We don't specify a given size
    my $child_space = $child_widget->get_desired_space();

    # scroll the space accordingly
    $child_space->set(
        x1 => $child_space->get_x1() + $self->{scroll_x}, y1 => $child_space->get_y1() + $self->{scroll_y},
        x2 => $child_space->get_x2() + $self->{scroll_x}, y2 => $child_space->get_y2() + $self->{scroll_y},
    );

    # A Scroll Area always grants the desired space
    $child_widget->_set_relatives_coordinates($child_space);
    $child_widget->can('_rebuild_children_coordinates')
        and $child_widget->_rebuild_children_coordinates();

    # take care of potential scrollbars
    if ( defined ($self->{v_scrollbar}) ) {

        my $c = $self->get_visible_shape;
        my ($child_widget)  = $self->get_children();
        my $child_rc = $child_widget->_get_relatives_coordinates();
        if ($child_rc->height <= $c->height) {
            $self->{v_scrollbar}->set_fill(1);
        } else {
            $self->{v_scrollbar}->set_fill($c->height / $child_rc->height);
        }
        # XXX FIXME This is a Hack
        $self->{v_scrollbar}->{coordinates} = Curses::Toolkit::Object::Coordinates->new(
            x1 => $c->get_x2()-1, y1 => $c->get_y1(),
            x2 => $c->get_x2(), y2 => $c->get_y2() - ( defined($self->{h_scrollbar}) ? 1 : 0),
        );

        # XXX FIXME This is a Hack
        $self->{v_scrollbar}->{theme_name} = $self->get_theme_name;
        $self->{v_scrollbar}->{theme} = $self->get_theme;
#        $self->{v_scrollbar}->draw();
    }
    return $self;
}

# overload the visible shape to take scrollbars in account
sub get_visible_shape_for_children {
    my ($self) = @_;
    my $shape = $self->get_visible_shape();
    if ($shape->width > 0) {
        $shape->set( x2 => $shape->get_x2() - 1);
    }
    if ($shape->height > 0) {
        $shape->set( y2 => $shape->get_y2() - 1);
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
    my ($child_widget)  = $self->get_children();
    defined $child_widget
      or return Curses::Toolkit::Object::Coordinates->new_zero();
    return $child_widget->relatives_coordinates()->clone;
}

1;
