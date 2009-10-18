use warnings;
use strict;

package Curses::Toolkit::EventListener;
# ABSTRACT: base class for event listeners

use Params::Validate qw(:all);

=head1 DESCRIPTION

Base class for event listener. An event listener is an object that is attached
to a widget / window / root window, that is capable of saying if it can handle
a given event, and if yes, performs specific action on it.

=head1 CONSTRUCTOR

=head2 new

=cut

sub new {
    my $class = shift;
    my %params = validate(@_, { accepted_event_class => { type => SCALAR },
								conditional_code => { type => CODEREF },
								code => { type => CODEREF },
							  }
                         );
	$params{enabled} = 1;
	return bless { %params }, $class;
}

=head1 METHODS

=head2 can_handle

Given an event, returns true if the listener is capable of handling this event

  input : a Curses::Toolkit::Event
  output : true or false

=cut

sub can_handle {
	my $self = shift;
	my ($event) = validate_pos( @_, { isa => 'Curses::Toolkit::Event' } );
	$event->isa($self->{accepted_event_class}) or return;
	$self->{conditional_code}->($event) or return;
	return 1;
}

=head2 send_event

Given an event, send it to the listener.
Returns the result of the event code.

  input : a Curses::Toolkit::Event
  output : the result of the event code execution

=cut

sub send_event {
	my $self = shift;
	my ($event, $widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Event' }, 1 );
	return $self->{code}->($event, $widget);	
}

=head2 enable

Enables the event listener (by default the listener is enabled)

  input  : none
  output : the event listener

=cut

sub enable {
	my ($self) = @_;
	$self->{enabled} = 1;
	return $self;
}

=head2 disable

Disables the event listener

  input  : none
  output : the event listener

=cut

sub disable {
	my ($self) = @_;
	$self->{enabled} = 0;
	return $self;
}

=head2 is_enabled

Return the state of the listener

input  : none
output : true or false

=cut

sub is_enabled {
	my ($self) = @_;
	return $self->{enabled} ? 1 : 0;
}

=head2 is_attached

Returns true if the event listener is already attached to a widget

  input  : none
  output : true or false

=cut

sub is_attached {
	my ($self) = @_;
	defined $self->{attached_to} and return 1;
	return;
}

=head2 detach

detach the event listener from the widget it is attached to.

  input  : none
  output : the event listener

=cut

sub detach {
	my ($self) = @_;
	$self->is_attached() or die "the event listener is not attached";
	my $widget = $self->{attached_to};
	my $index = $self->{attached_index};
	if (defined $widget && defined $index) {
		$widget->_remove_event_listener($index);
	}
	delete $self->{attached_to};
	delete $self->{attached_index};
	return $self;
}

# set the widget to which the event listener is attached
# input  : a Curses::Toolkit::Widget
#          the index
# output : the event listener
sub _set_widget {
	my $self = shift;
	my ($widget, $index) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' },
										     { type => BOOLEAN },
									   );
	$self->{attached_to} = $widget;
	$self->{attached_index} = $index;
	return $self;
}

# destroyer
DESTROY {
    my ($self) = @_;
	$self->is_attached() and $self->detach();
}

1;
