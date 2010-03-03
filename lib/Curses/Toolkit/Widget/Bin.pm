use warnings;
use strict;

package Curses::Toolkit::Widget::Bin;

# ABSTRACT: a bin widget

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

=head1 DESCRIPTION

This widget can contain 0 or 1 other widgets.

=cut

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Bin

=cut

=head1 METHODS

=head2 add_widget

Add a widget as unique child. Only one widget can be added. Fails if a child
already exists. Call remove_widget() if you want to call add_widget() again. To
know if there is already a widget, call get_children().

The added child widget takes all the available space.

  input  : the child widget
  output : the current widget (not the child widget)

=cut

sub add_widget {
    my $self = shift;
    my ($child_widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' } );
    scalar $self->get_children()
        and die 'there is already a child widget';
    $self->_add_child($child_widget);
    $child_widget->_set_parent($self);

    # because it's a Bin container, needs to take care of rebuilding coordinates
    # from top to bottom
    $self->rebuild_all_coordinates();
    return $self;
}


=head2 remove_widget

Removes the child widget.

  input  : none
  output : the current widget (not the child widget)

=cut

sub remove_widget {
    my ($self) = @_;
    my @children = ();

    $self->{children} = Tie::Array::Iterable->new(@children);
    return $self;
}

sub _rebuild_children_coordinates {
    my ($self)          = @_;
    my $available_space = $self->_get_available_space();
    my ($child_widget)  = $self->get_children();
    defined $child_widget or return;

    # Given the available space, how much does the child widget want ?
    my $child_space = $child_widget->get_desired_space( $available_space->clone() );

    # Make sure it's not bigger than what is available
    $child_space->restrict_to($available_space);

    # 		# Force the child space to be as large as the available space
    # 		$child_space->set(x2 => $available_space->get_x2() );
    # At the end, we grant it this space
    $child_widget->_set_relatives_coordinates($child_space);
    $child_widget->can('_rebuild_children_coordinates')
        and $child_widget->_rebuild_children_coordinates();
    return $self;
}

1;
