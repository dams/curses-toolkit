use warnings;
use strict;

package POE::Component::Curses;

# ABSTRACT: the ( currently only ) loader for Curses::toolkit

use POE::Component::Curses::MainLoop;

use POE qw(Session);
use POE qw(Wheel::Curses);
use Params::Validate qw(:all);

=head1 SYNOPSIS

  # spawn a root window
  my $root_window = POE::Component::Curses->spawn();
  # adds some widget
  $root->add_window(
      my $window = Curses::Toolkit::Widget::Window
        ->new()
        ->set_name('main_window')
        ->add_widget(
          my $border1 = Curses::Toolkit::Widget::Border
            ->new()
            ->set_name('border1')
            ->add_widget(
              my $label1 = Curses::Toolkit::Widget::Label
                ->new()
                ->set_name('label1')
                ->set_text('This demonstrates the use of Curses::Toolkit used with its POE Event Loop : POE::Component::Curses. Keyboard events and window resizing are supported')
            ),
        )
        ->set_coordinates(x1 => 0,   y1 => 0,
                          x2 => '100%',
                          y2 => '100%',
                         )
  );

  # start main loop
  POE::Kernel->run();

=head1 DESCRIPTION

POE::Component::Curses is a mainloop for L<Curses::Toolkit>.

It has only one method : C<spawn>, which instantiates and returns a
L<Curses::Toolkit> object for you. This is the root window.

You should use this object to populate your root window with widgets. See
L<Curses::Toolkit> for more information.

=head1 CLASS METHODS

=head2 spawn

This is the main method. It will create and return a L<Curses::Toolkit> object,
and create a POE Session that will be the mainloop. C<spawn> takes as argument
the optional alias you want to give to this POE Session (default is
C<'curses'>), and an optional C<args> which is a hashref. It should contain
arguments that will be passed to the C<init_root_window> of L<Curses::Toolkit>.
See its documentation for more information

  input  : alias <String> : the name of the POE Session. Default : 'curses'
         : args <HashRef> : the arguments to be passed to C<Curses::Toolkit::init_root_window>
  output : a L<Curses::Toolkit> instance

=cut

sub spawn {
    my $class = shift;

    my %params = validate(
        @_,
        {   alias => { default  => 'curses' },
            args  => { optional => 1, type => HASHREF }
        }
    );

    # setup mainloop and root toolkit object
    my $mainloop = POE::Component::Curses::MainLoop->new(
        session_name => $params{alias},
        defined $params{args} ? ( args => $params{args} ) : ()
    );
    POE::Session->create(
        inline_states => {
            _start => sub {
                my ( $kernel, $session, $heap ) = @_[ KERNEL, SESSION, HEAP ];

                # save the mainloop
                $heap->{mainloop} = $mainloop;

                # give a name to the session
                $kernel->alias_set( $params{alias} );

                # listen for window resize signals
                $kernel->sig( WINCH => 'pre_window_resize' );

                # now listen to the keys
                $_[HEAP]{console} = POE::Wheel::Curses->new(
                    InputEvent => 'key_handler',
                );

                # ask the mainloop to rebuild_all coordinate
                $kernel->yield('rebuild_all');

            },
            key_handler => sub {
                my ( $kernel, $heap, $keystroke ) = @_[ KERNEL, HEAP, ARG0 ];
                use Data::Dumper;

                #				my $k = $keystroke;
                #				while(length $k) {
                #					my $c = substr($k, 0, 1, '');
                #					print STDERR sprintf(" -- A D H O  : [%s] [%d] [%x] [%o]- \n", $c, ord($c), ord($c), ord($c));
                #				}
                use Curses; # for keyname and unctrl
                if ( $keystroke ne -1 ) {
                    if ( $keystroke lt ' ' ) {
                        $keystroke = '<' . uc( unctrl($keystroke) ) . '>';
                    } elsif ( $keystroke =~ /^\d{2,}$/ ) {
                        $keystroke = '<' . uc( keyname($keystroke) ) . '>';
                    }
                    if ( $keystroke eq '<KEY_RESIZE>' ) {

                        # don't handle this here, it's handled in window_resize
                        return;
                    } elsif ( $keystroke eq '<KEY_MOUSE>' ) {

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


                        my ( $id, $x, $y, $z, $bstate ) = unpack( "sx2i3l", $mouse_curses_event );
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
                            if ( !$@ && $bstate == $possible_event ) {
                                my ( $button, $type2 ) = $possible_event_name =~ /^([^_]+)_(.+)$/;
                                $heap->{mainloop}->event_mouse(
                                    type   => 'click',
                                    type2  => lc($type2),
                                    button => lc($button),
                                    x      => $x,
                                    y      => $y,
                                    z      => $z,
                                );
                            }
                        }

                    } else {

                        if ( $keystroke eq '<^L>' ) {
                            $kernel->yield('window_resize');
                        } elsif ( $keystroke eq '<^C>' ) {
                            exit();
                        } else {
                            $heap->{mainloop}->event_key(
                                type => 'stroke',
                                key  => $keystroke,
                            );
                        }
                    }
                }
            },
            pre_window_resize => sub {

                # This is a hack : it seems the window resize is one event
                # late, so we issue an additional one a bit later
                my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
                $kernel->yield('window_resize');
                $kernel->delay( window_resize => 1 / 10 );
            },
            window_resize => sub {
                my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
                $heap->{mainloop}->event_resize();
            },
            rebuild_all => sub {
                my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
                $heap->{mainloop}->event_rebuild_all();
            },

            # Now the Mainloop signals
            redraw => sub {
                my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
                $heap->{mainloop}->event_redraw();
            },
            add_delay_handler => sub {
                my $seconds = $_[ARG0];
                my $code    = $_[ARG1];
                $_[KERNEL]->delay_set( 'delay_handler', $seconds, $code, @_[ ARG2 .. $#_ ] );
            },
            delay_handler => sub {
                my $code = $_[ARG0];
                $code->( @_[ ARG1 .. $#_ ] );
            },
            stack_event => sub {
                my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
                $heap->{mainloop}->event_generic( @_[ ARG0 .. $#_ ] );
                }
        }
    );
    return $mainloop->get_toolkit_root();
}

1;
