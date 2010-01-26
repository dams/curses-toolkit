use warnings;
use strict;

package Curses::Toolkit::Event;
# ABSTRACT: base class for events

use Params::Validate qw(:all);

=head1 DESCRIPTION

Base class for events

=head1 CONSTRUCTOR

None, this is an abstract class, please use one of the children

=head1 Event Propagation

By default, an event can "propagate" : if 2 event listeners ( see
L<EventListener>) can handle an event, the event will be given to the 2
listeners, in the order the listeners were created and associated to the widget.

However, if you disable propagation, the event will be given to the first
listener that can handle it, and that's it. Even if others listeners could
handle it in the row, they won't be executed.

=head1 Event Restriction to the widget

By default, an event is not restricted to a widget : if there is no listener
matching the event, attached to the widget, the event is given to the parent
widget recursively.

However, if you enable event restriction, the event will not be passed to the
parent widget. Only the listener of the widget will be tested.

=cut

sub new {
    my $class = shift;
    $class eq __PACKAGE__ and die "abstract class";
	return bless { can_propagate => 1,
				   restricted => 0,
				 }, $class;
}

=head1 METHODS

=head2 get_type

Returns the type of the event

=cut

sub get_type {
	my ($self) = @_;
	return $self->{type};
}

=head2 enable_propagation

Enable propagation of the event to other matching listeners

=cut

sub enable_propagation {
	my ($self) = @_;
	$self->{can_propagate} = 0;
	return $self;
}

=head2 disable_propagation

Disable propagation of the event to other matching listeners

=cut

sub disable_propagation {
	my ($self) = @_;
	$self->{can_propagate} = 1;
	return $self;
}

=head2 can_propagate

Returns wether the event can propagate

=cut

sub can_propagate {
	return shift->{can_propagate};
}

=head2 enable_restriction

Enable restriction of the event to the original widget : the event won't be
passed to parent widgets

=cut

sub enable_restriction {
	my ($self) = @_;
	$self->{restricted} = 1;
	return $self;
}

=head2 disable_restriction

Disable restriction of the event to the original widget : the event will be
passed to parent widgets

=cut

sub disable_restriction {
	my ($self) = @_;
	$self->{restricted} = 0;
	return $self;
}

=head2 restricted_to_widget

Returns wether the event is restricted to the widget

=cut

sub restricted_to_widget {
	return shift->{restricted};
}

1;
