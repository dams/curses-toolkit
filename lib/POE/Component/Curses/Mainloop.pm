package POE::Component::Curses::MainLoop;

use strict;
use warnings;

use POE qw(Session);
use Params::Validate qw(:all);

use Curses::Toolkit;

=head1 NAME

POE::Component::Curses::MainLoop

=head1 SYNOPSIS

This module is not for you !

You should not use this module directly. It's used by L<POE::Component::Curses>
as a MainLoop interface to L<Curses::Toolkit>

Please look at L<POE::Component::Curses>. Thanks !

=cut

# OK so this creates the mainlopp object. IT's the bridge between the POE
# Component and the Curses Toolkit root object.

sub new {
	my $class = shift;

	my %params = validate( @_, { session_name => { optional => 1, type => SCALAR },
							   }
						 );
	my $toolkit_root = Curses::Toolkit->init_root_window();
	my $self = bless( { toolkit_root => $toolkit_root,
						session_name => $params{session_name},
					  }, $class);
	$toolkit_root->set_mainloop($self);
	return $self;
}

sub set_session_name {
	my $self = shift;
	my ($session_name) = validate_pos( @_, { type => SCALAR } );
	return $self;
}

sub get_toolkit_root {
	my ($self) = @_;
	return $self->{toolkit_root};
}


#### Now implement the Mainloop API ####

## Methods called by the Curses::Toolkit objects ##
## They usually returns $self, or a return value

sub needs_redraw {
	my ($self) = @_;
	# if redraw is already stacked, just quit
	$self->{needs_redraw_bool} and return;
	$self->{needs_redraw_bool} = 1;
	$poe_kernel->post($self->{session_name}, 'redraw');
	return $self;
}


## Methods called by the POE Component session ##
## They usually return nothing

# POE::Component::Curses ordered a redraw
sub event_redraw {
	my ($self) = @_;
	# set his to 0 so redraw requests that may appear in the mean time will be
	# granted
	$self->{needs_redraw_bool} = 0;

	$self->{toolkit_root}->render();
	$self->{toolkit_root}->display();
	return;
}

# POE::Component::Curses iformed on a window resize event
sub event_resize {
	my ($self) = @_;

	use Curses::Toolkit::Event::Shape;
	my $event = Curses::Toolkit::Event::Shape->new( type => 'change' );
	$self->{toolkit_root}->dispatch_event($event);
	return;
}

1;
