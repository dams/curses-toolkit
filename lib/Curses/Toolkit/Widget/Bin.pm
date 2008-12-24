package Curses::Toolkit::Widget::Bin;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::Bin - a bin widget

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
	scalar $self->get_children() and
	  die 'there is already a child widget';
	$self->SUPER::add_widget($child_widget);
	return $self;
}

=head2 remove_widget

Removes the child widget.

  input  : none
  output : the current widget (not the child widget)

=cut

sub remove_widget {
	my ($self) = @_;
	$self->{children} = [];
	return $self;
}

1;
