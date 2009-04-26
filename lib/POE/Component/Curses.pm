package POE::Component::Curses;

use POE::Component::Curses::MainLoop;

use strict;
use warnings;

our $VERSION = '0.01';

use Curses;
use Curses::Toolkit;

use POE qw(Session);
use POE qw(Wheel::Curses);
use Params::Validate qw(:all);

sub spawn {
	my $class = shift;

	my %params = validate( @_, { alias => { default => 'curses' },
							   }
						  );

	# setup mainloop and root toolkit object
	my $mainloop = POE::Component::Curses::MainLoop->new();
	my $toolkit_root = Curses::Toolkit->init_root_window(clear => 0,
														 mainloop => $mainloop);
	$mainloop
	  ->set_session_name($params{alias})
		->set_toolkit_root($toolkit_root);

	POE::Session->create(
		inline_states => {
			_start => sub {
				my ($kernel, $session, $heap) = @_[KERNEL, SESSION, HEAP];
				# give a name to the session
				$kernel->alias_set($params{alias});

				$heap->{mainloop} = $mainloop;
				$heap->{toolkit_root} = $toolkit_root;

				# now listen to the keys
				$_[HEAP]{console} = POE::Wheel::Curses->new(
				  InputEvent => 'key_handler',
				);
			},
			key_handler => sub {
				my ($kernel, $heap, $keystroke) = @_[ KERNEL, HEAP, ARG0];
				if ($keystroke ne -1) {
					if ($keystroke lt ' ') {
						print STDERR " %%% 1 [$keystroke]\n";
						$keystroke = '<' . uc(unctrl($keystroke)) . '>';
					} elsif ($keystroke =~ /^\d{2,}$/) {
						print STDERR " %%% 2 [$keystroke]\n";
						$keystroke = '<' . uc(keyname($keystroke)) . '>';
					}
					print STDERR "handler got $keystroke\n";
				}
			},
        }
	);
	return $toolkit_root;
}

1;
