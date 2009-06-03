package Curses::Toolkit::EventListener;

use warnings;
use strict;

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::EventListener - base class for event listeners

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
	return bless { %params }, $class;
}

sub can_handle {
	my $self = shift;
	my ($event) = validate_pos( @_, { isa => 'Curses::Toolkit::Event' } );
	$event->isa($self->{accepted_event_class}) or return;
	$self->{conditional_code}->($event) or return;
	return 1;
}

sub send_event {
	my $self = shift;
	my ($event) = validate_pos( @_, { isa => 'Curses::Toolkit::Event' } );
	return $self->{code}->($event);	
}

1;
