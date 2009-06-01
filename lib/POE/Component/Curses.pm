package POE::Component::Curses;

use POE::Component::Curses::MainLoop;

use strict;
use warnings;

our $VERSION = '0.01';


use POE qw(Session);
use POE qw(Wheel::Curses);
use Params::Validate qw(:all);

sub spawn {
	my $class = shift;

	my %params = validate( @_, { alias => { default => 'curses' },
							   }
						  );

	# setup mainloop and root toolkit object
	my $mainloop = POE::Component::Curses::MainLoop->new(session_name => $params{alias});
	POE::Session->create(
		inline_states => {
			_start => sub {
				my ($kernel, $session, $heap) = @_[KERNEL, SESSION, HEAP];

				# save the mainloop
				$heap->{mainloop} = $mainloop;

				# give a name to the session
				$kernel->alias_set($params{alias});

				# listen for window resize signals
				$kernel->sig(WINCH => 'pre_window_resize');

				# now listen to the keys
				$_[HEAP]{console} = POE::Wheel::Curses->new(
				  InputEvent => 'key_handler',
				);
			},
			key_handler => sub {
				my ($kernel, $heap, $keystroke) = @_[ KERNEL, HEAP, ARG0];
				use Curses; # for keyname and unctrl
				if ($keystroke ne -1) {
					if ($keystroke lt ' ') {
						$keystroke = '<' . uc(unctrl($keystroke)) . '>';
					} elsif ($keystroke =~ /^\d{2,}$/) {
						$keystroke = '<' . uc(keyname($keystroke)) . '>';
					}
					if ($keystroke eq '<KEY_RESIZE>') {
						# don't handle this here, it's handled in window_resize
						return;
					}
					print STDERR " GOT [$keystroke]\n";

					if ($keystroke eq 'j') {
						$kernel->post($params{alias}, 'window_resize');
					} elsif ($keystroke eq '<^I>') {
						$kernel->post($params{alias}, 'window_resize');
					} elsif ($keystroke eq 'q') {
						exit();
					} else {
						$heap->{mainloop}->event( type => 'key',
												  keystroke => $keystroke
												);
					}
				}
			},
			pre_window_resize => sub {
				# This is a hack : it seems the window resize is one event
				# late, so we issue an additional one a bit later
				my ($kernel, $heap) = @_[ KERNEL, HEAP];
				$kernel->yield('window_resize');
				$kernel->delay(window_resize => 1/10);
			},
			window_resize => sub { 
				my ($kernel, $heap) = @_[ KERNEL, HEAP];

# 				$class->restart_curses();
# 				my %sessions = $class->get_sessions();
# 				my @sessions_names = keys(%sessions);
# 				# send the window_resize to all sessions (including root)
# 				foreach my $name (@sessions_names) {
# 					# window resize signal provided by default (see Session.pm)
# 					$kernel->call($name, '__window_resize');
# 				}

				$heap->{mainloop}->event_resize();

			},

			# Now the Mainloop signals
			redraw => sub {
				my ($kernel, $heap) = @_[KERNEL, HEAP];
				$heap->{mainloop}->event_redraw();
			},
        }
	);
	return $mainloop->get_toolkit_root();
}

1;
