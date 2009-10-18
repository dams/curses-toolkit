use warnings;
use strict;

package POE::Component::Curses::MainLoop;
# ABSTRACT: <FIXME to be filled>

use POE qw(Session);
use Params::Validate qw(:all);

use Curses::Toolkit;

=head1 SYNOPSIS

This module is not for you !

You should not use this module directly. It's used by L<POE::Component::Curses>
as a MainLoop interface to L<Curses::Toolkit>

Please look at L<POE::Component::Curses>. Thanks !

=cut

# OK so this creates the mainlopp object. It's the bridge between the POE
# Component and the Curses Toolkit root object.

sub new {
	my $class = shift;

	my %params = validate( @_, { session_name => { optional => 1, type => SCALAR },
								 args => { optional => 1, type => HASHREF, default => {} }
							   }
						 );
	my $toolkit_root = Curses::Toolkit->init_root_window( %{$params{args}} );
	my $self = bless( { toolkit_root => $toolkit_root,
						session_name => $params{session_name},
					  }, $class);
	$toolkit_root->set_mainloop($self);
	return $self;
}

sub set_session_name {
	my $self = shift;
	my ($session_name) = validate_pos( @_, { type => SCALAR } );
	$self->{session_name} = $session_name;
	return $self;
}

sub get_toolkit_root {
       my ($self) = @_;
       return $self->{toolkit_root};
}


# sub set_session {
# 	my $self = shift;
# 	my ($session) = validate_pos( @_, { isa => 'POE::Session' } );
# 	$self->{session} = $session;
# 	return $self;
# }


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

sub add_delay {
	my $self = shift;
	my $seconds = shift;
	my $code = shift;
	$poe_kernel->call($self->{session_name}, 'add_delay_handler', $seconds, $code, @_);
	return;
#	return $poe_kernel->delay_set('delay_handler', $seconds, $code, @_);
#	return $poe_kernel->delay_set('delay_handler', $seconds, $code, @_);
}


## Methods called by the POE Component session ##
## They usually return nothing

# POE::Component::Curses asked to rebuild all coordinates

sub event_rebuild_all {
	my ($self) = @_;
	$self->{toolkit_root}->_rebuild_all();	
	return;
}

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

# POE::Component::Curses informed on a window resize event
sub event_resize {
	my ($self) = @_;

	use Curses::Toolkit::Event::Shape;
	my $event = Curses::Toolkit::Event::Shape->new( type => 'change',
													root_window => $self->{toolkit_root}, );
	$self->{toolkit_root}->dispatch_event($event);
	return;
}

# POE::Component::Curses informed on a keyboard event
sub event_key {
	my $self = shift;

	my %params = validate( @_, {
								type => 1,
								key => 1 ,
							   }
						 );

	if ($params{type} eq 'stroke') {
		use Curses::Toolkit::Event::Key;
		my $event = Curses::Toolkit::Event::Key->new( type => 'stroke',
													  params => { key => $params{key}},
													  root_window => $self->{toolkit_root},
													);
		$self->{toolkit_root}->dispatch_event($event);
	}
	return;
}

# POE::Component::Curses informed on a mouse event
sub event_mouse {
	my $self = shift;

	my %params = validate( @_, {
								type => 1,
								type2 => 1,
								button => 1 ,
								x => 1,
								y => 1,
								z => 1,
							   }
						 );

	if ($params{type} eq 'click') {
		use Curses::Toolkit::Event::Mouse::Click;
		$params{type} = delete $params{type2};
		use Curses::Toolkit::Object::Coordinates;
		$params{coordinates} = Curses::Toolkit::Object::Coordinates->new( x1 => $params{x},
																		 x2 => $params{x},
																		 y1 => $params{y},
																		 y2 => $params{y},
																	   );
		delete @params{qw(x y z)};
		my $event = Curses::Toolkit::Event::Mouse::Click->new( %params,
															   root_window => $self->{toolkit_root} );
		$self->{toolkit_root}->dispatch_event($event);
	}
	return;
}

1;
