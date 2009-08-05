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
								 args => { optional => 1, type => HASHREF }
							   }
						  );

	# setup mainloop and root toolkit object
	my $mainloop = POE::Component::Curses::MainLoop->new(session_name => $params{alias}, defined $params{args} ? (args => $params{args}) : ());
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
					} elsif ($keystroke eq '<KEY_MOUSE>') {

						use Curses;
						my $mouse_curses_event = 0;
						# stolen from Curses::UI. Thanks ! :)
						getmouse($mouse_curses_event);

						# $mouse_curses_event is a struct. From curses.h (note: this might change!):
						#
						# typedef struct
						# {
						#    short id;           /* ID to distinguish multiple devices */
						#	 int x, y, z;        /* event coordinates (character-cell) */
						#	 mmask_t bstate;     /* button state bits */
						# } MEVENT;
						#
						# ---------------
						# s signed short
						# x null byte
						# x null byte
						# ---------------
						# i integer
						# ---------------
						# i integer
						# ---------------
						# i integer
						# ---------------
						# l long
						# ---------------
						
						
						my ($id, $x, $y, $z, $bstate) = unpack("sx2i3l", $mouse_curses_event);
						my @button_events = qw(
												BUTTON1_PRESSED BUTTON1_RELEASED BUTTON1_CLICKED BUTTON1_DOUBLE_CLICKED
												BUTTON1_TRIPLE_CLICKED BUTTON2_PRESSED BUTTON2_RELEASED BUTTON2_CLICKED
												BUTTON2_DOUBLE_CLICKED BUTTON2_TRIPLE_CLICKED BUTTON3_PRESSED BUTTON3_RELEASED
												BUTTON3_CLICKED BUTTON3_DOUBLE_CLICKED BUTTON3_TRIPLE_CLICKED BUTTON4_PRESSED
												BUTTON4_RELEASED BUTTON4_CLICKED BUTTON4_DOUBLE_CLICKED BUTTON4_TRIPLE_CLICKED
												BUTTON5_PRESSED BUTTON5_RELEASED BUTTON5_CLICKED BUTTON5_DOUBLE_CLICKED
												BUTTON5_TRIPLE_CLICKED BUTTON_SHIFT BUTTON_CTRL BUTTON_ALT
											 );
						foreach my $possible_event_name (@button_events) {
							my $possible_event = eval($possible_event_name);
							if (!$@ && $bstate == $possible_event) {
								my ($button, $type2) = $possible_event_name =~ /^([^_]+)_(.+)$/;
								$heap->{mainloop}->event_mouse( type => 'click',
																type2 => lc($type2),
																button => lc($button),
																x => $x,
																y => $y,
																z => $z,
															);
							}
						}
											
					} else {

						if ($keystroke eq '<^L>') {
							$kernel->post($params{alias}, 'window_resize');
						} elsif ($keystroke eq '<^C>') {
							exit();
						} else {
							$heap->{mainloop}->event_key( type => 'stroke',
														  key => $keystroke,
														);
						}
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

				$heap->{mainloop}->event_resize();

			},

			# Now the Mainloop signals
			redraw => sub {
				my ($kernel, $heap) = @_[KERNEL, HEAP];
				$heap->{mainloop}->event_redraw();
			},

			add_delay_handler => sub {
				my $seconds = $_[ARG0];
				my $code = $_[ARG1];
				$_[KERNEL]->delay_set('delay_handler', $seconds, $code, @_[ARG2..$#_]);
			},
			delay_handler => sub {
				my $code = $_[ARG0];
				$code->(@_[ARG1..$#_]);
			}
        }
	);
	return $mainloop->get_toolkit_root();
}

1;
