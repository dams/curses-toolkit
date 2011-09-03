use warnings;
use strict;

package Curses::Toolkit::EventListener;

# ABSTRACT: base class for event listeners

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

Base class for event listener. An event listener is an object that is attached
to a widget / window / root window, that is capable of saying if it can handle
a given event, and if yes, performs specific action on it.

=head1 CONSTRUCTOR

=head2 new

  input : accepted_events <HASHREF> : keys are a Event class, values are CODEREFs (see below)
          code <CODEREF> : code to be executed if an evet listener can handle the event

The CODEREfs receive an event as argument. If they return true, then the event
listener can handle this event

=cut

sub new {
    my $class  = shift;
    my %params = validate(
        @_,
        {   accepted_events => { type => HASHREF },
            code            => { type => CODEREF },
        }
    );
    $params{enabled} = 1;
    return bless {%params}, $class;
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
    my $event_class = ref $event;

    #	exists $self->{accepted_events}{$event_class} or return;
    if ( !exists $self->{accepted_events}{$event_class} ) {
        eval "require $event_class";
        $@ and die "failed requiring event class '$event_class'";
        my $found;
        foreach my $class_name ( keys %{ $self->{accepted_events} } ) {
            $event_class->isa($class_name)
                and $found = $class_name;
        }
        defined $found or return;
        $event_class = $found;
    }
    $self->{accepted_events}{$event_class}->($event) or return;
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
    my ( $event, $widget ) = validate_pos( @_, { isa => 'Curses::Toolkit::Event' }, 1 );
    return $self->{code}->( $event, $widget );
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
    my $index  = $self->{attached_index};
    if ( defined $widget && defined $index ) {
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
    my ( $widget, $index ) = validate_pos(
        @_, { isa => 'Curses::Toolkit::Widget' },
        { type => BOOLEAN },
    );
    $self->{attached_to}    = $widget;
    $self->{attached_index} = $index;
    return $self;
}

# destroyer
DESTROY {
    my ($self) = @_;
    $self->is_attached() and $self->detach();
}

1;
