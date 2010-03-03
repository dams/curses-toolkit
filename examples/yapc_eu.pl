#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

use POE;

sub main {

	close STDERR;
	open STDERR, '>/dev/null';
	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Entry;
	use Curses::Toolkit::Widget::HPaned;
	use Curses::Toolkit::Widget::Label;
	use Curses::Toolkit::Widget::Entry;

	my $root = POE::Component::Curses->spawn( args => { theme_name => 'Curses::Toolkit::Theme::Default' } );


	#1 ############# time label

	my ( $step1, $step2, $step3 );
	my ( $m, $s );
	$step1 = sub {
		my $move_label = 0;
		my $tick       = 0;

		my $time_window = Curses::Toolkit::Widget::Window->new();
		$time_window->set_name('time remaining'), $root->add_window($time_window);
		$time_window->set_theme_property( border_width => 0 );

		my $time_label = Curses::Toolkit::Widget::Label->new()->set_text('5:00')->set_name('label1');
		$time_window->add_widget($time_label);

		use Time::HiRes qw(time);
		POE::Session->create(
			inline_states => {
				_start => sub {
					$_[HEAP]->{min}             = 5;
					$_[HEAP]->{sec}             = 0;
					$_[HEAP]->{next_alarm_time} = int( time() ) + 1;
					$_[KERNEL]->alarm( tick => $_[HEAP]->{next_alarm_time} );
					$_[KERNEL]->delay_add( move_label => 1 / 10 );
				},
				tick => sub {
					if ($tick) {
						if ( $_[HEAP]->{sec} == 0 ) {
							if ( $_[HEAP]->{min} == 0 ) {
								print STDERR "timer elapsed\n";
							} else {
								$_[HEAP]->{min}--;
								$_[HEAP]->{sec} = 59;
							}
						} else {
							$_[HEAP]->{sec}--;
						}
						$time_label->set_text(
							$_[HEAP]->{min} . ':' . ( $_[HEAP]->{sec} < 10 ? '0' : '' ) . $_[HEAP]->{sec} );
						$root->needs_redraw();
					}
					$_[HEAP]->{next_alarm_time}++;
					$m = $_[HEAP]->{min};
					$s = $_[HEAP]->{sec};
					$_[KERNEL]->alarm( tick => $_[HEAP]->{next_alarm_time} );
				},
				move_label => sub {
					my ( $screen_h, $screen_w );
					if ($move_label) {
						$root->{curses_handler}->getmaxyx( $screen_h, $screen_w );
						my $c  = $time_label->get_coordinates();
						my $wc = $time_window->get_coordinates();
						my $nr = 0;
						int $c->get_x1() < $screen_w - 4 and $wc->set(
							x1 => $wc->get_x1() + 1,
							x2 => $wc->get_x() + 1
							),
							$nr = 1;
						int $c->get_x1() > $screen_w - 4 and $wc->set(
							x1 => $wc->get_x1() - 1,
							x2 => $wc->get_x() - 1
							),
							$nr = 1;
						int $c->get_y1() < 0 and $wc->set(
							y1 => $wc->get_y1() + 1,
							y2 => $wc->get_x() + 1
							),
							$nr = 1;
						int $c->get_y1() > 0 and $wc->set(
							y1 => $wc->get_y1() - 1,
							y2 => $wc->get_x() - 1
							),
							$nr = 1;
						$nr == 1 and $time_window->set_coordinates($wc);
						$nr == 1 and $root->needs_redraw();
					}
					$_[KERNEL]->delay_add( move_label => 1 / 6 );
				},
			},
		);

		my ( $screen_h, $screen_w );
		$root->{curses_handler}->getmaxyx( $screen_h, $screen_w );

		$time_window->set_coordinates(
			x1 => $screen_w / 2 - 2, y1 => $screen_h / 2,
			x2 => $screen_w / 2 + 2, y2 => $screen_h / 2 + 1,
		);

		$root->add_window(
			my $OK_window = Curses::Toolkit::Widget::Window->new()->set_theme_property( border_width => 0 )->add_widget(
				my $button1 =
					Curses::Toolkit::Widget::Button->new_with_label('Hit space when you are ready to start!')
					->add_event_listener(
					Curses::Toolkit::EventListener->new(
						accepted_event_class => 'Curses::Toolkit::Event::Key',
						conditional_code     => sub {
							my ($event) = @_;
							$event->{type} eq 'stroke' or return 0;
							$event->{params}{key} eq ' ' or return 0;
						},
						code => sub {
							my ( $event, $button ) = @_;
							$move_label = 1;
							$tick       = 1;
							$button->get_parent()->remove_widget();
							POE::Session->create(
								inline_states => {
									_start => sub {
										$poe_kernel->delay_add( start_step2 => 3 );
									},
									start_step2 => sub {
										$step2->();
									},
								}
							);
						},
					)
					)
				)->set_coordinates(
				x1 => ( $screen_w - 40 ) / 2,
				y1 => $screen_h / 2 + 1,
				x2 => ( $screen_w + 45 ) / 2,
				y2 => $screen_h / 2 + 2,
				)
		);
		$OK_window->set_theme_property( border_width => 0 );
		$button1->set_focus(1);
	};

	my $audience_window;
	my $audience_entry;
	my $label;

	my $flag;

	$step2 = sub {
		$root->add_window( my $window = Curses::Toolkit::Widget::Window->new()->set_title("This is a long title") );
		$window->set_theme_property( border_width => 0 );
		$window->set_coordinates(
			x1 => 3, y1 => '55%',

			#							  x2 => 50, y2 => 80,
			x2 => '100%', y2 => '100%',
		);
		$window->add_widget(
			$label = Curses::Toolkit::Widget::Label->new()->set_text(
				"Hello !                                                                           .\n                                                                           .\n                                                                           .\n                                                                           .\n                                                                           .\n\n\n"
			)
		);
		my $app = sub { $label->set_text( $label->get_text() . $_[0] ) };
		my $set = sub { $label->set_text( $_[0] ) };
		my $o   = 0;
		my $t   = sub { $o += ( $_[0] / 1 ); return $o; };
		$root->add_delay( $t->(5), sub { $set->("My name is Damien Krotkine\n") } );
		$root->add_delay( $t->(3), sub { $app->("I'm also known as 'dams'\n") } );
		$root->add_delay( $t->(3), sub { $set->("\n") } );
		$root->add_delay( $t->(3), sub { $set->("I am not the funny guy which is standing on the scene.\n") } );
		$root->add_delay( $t->(5), sub { $app->("The funny guy is called BooK, and I'm sure you all know him.") } );
		$root->add_delay(
			$t->(5),
			sub { $set->("I couldn't make it to the YAPC::EU this year\nso I asked Book to give this talk for me !") }
		);
		$root->add_delay( $t->(7), sub { $set->("") } );
		$root->add_delay( $t->(3), sub { $set->("OK. So what is this talk about ?\n") } );
		$root->add_delay( $t->(5), sub { $set->("this talk is about : ") } );
		$root->add_delay( $t->(5), sub { $app->("    Curses::Toolkit   !") } );
		$root->add_delay( $t->(5), sub { $set->("Curses::Toolkit is a\n") } );
		$root->add_delay( $t->(2), sub { $app->("modern ") } );
		$root->add_delay( $t->(1), sub { $app->("POE based ") } );
		$root->add_delay( $t->(1), sub { $app->("object oriented ") } );
		$root->add_delay( $t->(1), sub { $app->("widget oriented ") } );
		$root->add_delay( $t->(1), sub { $app->("GTK inspired ") } );
		$root->add_delay( $t->(1), sub { $app->("curses ") } );
		$root->add_delay( $t->(1), sub { $app->("toolkit !\n") } );
		$root->add_delay( $t->(5), sub { $set->("") } );
		$root->add_delay( $t->(5), sub { $set->("Book is kind enough to do things for me\n") } );
		$root->add_delay( $t->(2), sub { $app->("So I'll use that opportunity to ask him to help me\n") } );
		$root->add_delay( $t->(2), sub { $app->("While I'm demonstrating some features of Curses::Toolkit\n") } );
		$root->add_delay( $t->(5), sub { $set->("") } );
		$root->add_delay( $t->(2), sub { $set->("Book recently won the White Camel Award !\n") } );
		$root->add_delay( $t->(2), sub { $app->("So I think he deserves a lot of applause !\n") } );
		$root->add_delay( $t->(2), sub { $app->(" (Book, at this point, I suggest you bow)!\n") } );
		$root->add_delay(
			$t->(10),
			sub { $set->(" OK ! now back to business (Book, you can put your T-Shirt back on)\n") }
		);

		my $audience_label;
		$root->add_delay( $t->(5), sub { $set->("Let's start with a window\n"); } );
		$root->add_delay(
			$t->(2),
			sub {
				$root->add_window( $audience_window = Curses::Toolkit::Widget::Window->new() );
				$audience_window->set_coordinates(
					x1 => 3,  y1 => 3,
					x2 => 40, y2 => 10,
				);
				$audience_window->add_widget( $audience_label =
						Curses::Toolkit::Widget::Label->new()->set_text("Wow this is a cool window !") );

			}
		);
		$root->add_delay( $t->(2), sub { $app->("oh it's new and shiny !\n") } );
		$root->add_delay(
			$t->(2),
			sub {
				$set->(
					"The good thing about Curses::Toolkit is that\nyou don't have to mess with cordinates, the module handles it for you\n"
				);
			}
		);
		$root->add_delay( $t->(5), sub { $set->("For instance, I can move and resize the window\n") } );


		my $move_audience_window_sub;
		my $move_audience_window_sub2;
		my $loop1 = 20;
		my $loop2 = 12;
		$move_audience_window_sub = sub {
			my $wc = $audience_window->get_coordinates();
			$audience_window->set_coordinates(
				x1 => $wc->get_x1() + 1, x2 => $wc->get_x(),
				y1 => $wc->get_y1(),     y2 => $wc->get_y2()
			);
			$loop1-- and $root->add_delay( 1 / 3, $move_audience_window_sub );
		};
		$move_audience_window_sub2 = sub {
			my $wc = $audience_window->get_coordinates();
			$audience_window->set_coordinates(
				x1 => $wc->get_x1() - 1, x2 => $wc->get_x() + 1,
				y1 => $wc->get_y1(),     y2 => $wc->get_y2()
			);
			$loop2-- and $root->add_delay( 1 / 3, $move_audience_window_sub2 );
		};
		$root->add_delay( $t->(2),  $move_audience_window_sub );
		$root->add_delay( $t->(10), $move_audience_window_sub2 );
		$root->add_delay( $t->(5),  sub { $set->("I can also set a title\n") } );
		$root->add_delay(
			$t->(3),
			sub {
				$audience_window->set_theme_property( title_width => 50 );
				$audience_window->set_title("title");
			}
		);
		$root->add_delay( $t->(5),  sub { $set->("If the title is too big, it's animated\n") } );
		$root->add_delay( $t->(3),  sub { $audience_window->set_title("this is truely a very long title. fear !") } );
		$root->add_delay( $t->(5),  sub { $set->("") } );
		$root->add_delay( $t->(10), sub { $set->("All this is themable\n") } );
		$root->add_delay( $t->(2),  sub { $app->("I'll try to change the theme of the window\n") } );
		$root->add_delay( $t->(2),  sub { $app->("... hmmm let's seee....\n") } );
		$root->add_delay(
			$t->(4),
			sub {
				$audience_window->{theme} = Curses::Toolkit::Theme::Default::Color::Pink->new($audience_window);
				$audience_label->{theme}  = Curses::Toolkit::Theme::Default::Color::Pink->new($audience_label);
				$audience_window->set_theme_property( title_width => 50 );
				$root->needs_redraw();
			}
		);
		$root->add_delay( $t->(2), sub { $set->("There !") } );
		$root->add_delay( $t->(2), sub { $app->(" ... nice, uh ?") } );
		$root->add_delay( $t->(2), sub { $set->("") } );
		$root->add_delay( $t->(2), sub { $set->("Now the big show\n") } );
		$root->add_delay( $t->(2), sub { $app->("Mouse interactions !!\n") } );
		$root->add_delay( $t->(4), sub { $set->("Mr Book, can you please move the window\n") } );
		$root->add_delay( $t->(2), sub { $app->("by drag and dropping its title bar ?\n") } );
		$root->add_delay( $t->(2), sub { $app->("I'll give you 20 secs to play\n") } );

		my $loop3 = 20;
		my $sub3;
		$sub3 = sub {
			$audience_label->set_text("  ^ move me ^ ! $loop3 secs");
			$loop3-- and $root->add_delay( 1, $sub3 );
		};
		$root->add_delay( $t->(1), $sub3 );
		$root->add_delay( $t->(11), sub { $set->("10 secs left") } );
		$root->add_delay(
			$t->(10),
			sub {
				$set->("");
				$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
			}
		);
		$root->add_delay( $t->(2), sub { $set->("OK now, resize it please !") } );

		my $loop4 = 20;
		my $sub4;
		$sub4 = sub {
			$audience_label->set_text("  resize me ! $loop4 secs");
			$loop4-- and $root->add_delay( 1, $sub4 );
		};
		$root->add_delay( $t->(1), $sub4 );
		$root->add_delay( $t->(11), sub { $set->("10 secs left") } );
		$root->add_delay(
			$t->(10),
			sub {
				$set->("");
				$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
			}
		);
		$root->add_delay( $t->(2), sub { $set->("funny, isn't it ? ") } );
		$root->add_delay( $t->(4), sub { $set->("Let's try to see more widgets\n") } );
		$root->add_delay( $t->(2), sub { $app->("Let's have a look at boxes, Entry and Button") } );
		my $audience_button;
		$root->add_delay(
			$t->(2),
			sub {
				$audience_window->remove_widget();
				my $vbox = Curses::Toolkit::Widget::VBox->new();
				$audience_window->add_widget($vbox);
				$vbox->pack_end(
					$audience_entry =
						Curses::Toolkit::Widget::Entry->new_with_text('Enter some text')->set_name('entry1'),
					{ expand => 1 }
					)->pack_end(
					my $hbox = Curses::Toolkit::Widget::HBox->new()->pack_end(
						$audience_button = Curses::Toolkit::Widget::Button->new_with_label(' OK ')->set_name('button1'),
						{ expand => 0 }
					),
					{ expand => 0 }
					);
				$audience_button->add_event_listener(
					Curses::Toolkit::EventListener->new(
						accepted_event_class => 'Curses::Toolkit::Event::Key',
						conditional_code     => sub {
							my ($event) = @_;
							$event->{type} eq 'stroke' or return 0;
							$event->{params}{key} eq ' ' or return 0;
						},
						code => sub {
							my ( $event, $button ) = @_;
							$step3->();
						},
					)
				);
				$audience_window->{theme} = Curses::Toolkit::Theme::Default::Color::Yellow->new($audience_window);
				$audience_window->set_theme_property( title_width => 50 );
				$audience_entry->{theme}  = Curses::Toolkit::Theme::Default::Color::Yellow->new($audience_entry);
				$audience_button->{theme} = Curses::Toolkit::Theme::Default::Color::Yellow->new($audience_button);
				$hbox->{theme}            = Curses::Toolkit::Theme::Default::Color::Yellow->new($hbox);
				$vbox->{theme}            = Curses::Toolkit::Theme::Default::Color::Yellow->new($vbox);
				$audience_button->set_focus(1);
				$root->needs_redraw();
			}
		);
		$root->add_delay( $t->(1), sub { $set->("") } );
		$root->add_delay(
			$t->(1),
			sub { $set->("Please enter something in the entry and hit space on the button\n") }
		);
		$root->add_delay( $t->(2),  sub { $app->("You can use <tab> to navigate between widgets\n") } );
		$root->add_delay( $t->(2),  sub { $app->("Select the entry and hit Enter. Then : \n") } );
		$root->add_delay( $t->(1),  sub { $app->("You can use <Ctrl-A> and <Ctrl-E> to navigate\n") } );
		$root->add_delay( $t->(1),  sub { $app->("You can use the arrows, and <Ctrl-D> and maybe backspace\n") } );
		$root->add_delay( $t->(20), sub { $flag or $step3->(); } );
	};

	$step3 = sub {
		$flag = 1;
		$audience_window->remove_widget();
		my $app = sub { $label->set_text( $label->get_text() . $_[0] ) };
		my $set = sub { $label->set_text( $_[0] ) };
		my $o   = 0;
		my $t   = sub { $o += ( $_[0] / 1 ); return $o; };
		my $text = $audience_entry->get_text();
		$root->add_delay( $t->(1), sub { $set->(" You entered the text : '$text'") } );
		$root->add_delay( $t->(5), sub { $set->("OK ! Let's have a look at the Paned widget ! ") } );
		$root->add_delay(
			$t->(2),
			sub {
				my $hpane = Curses::Toolkit::Widget::HPaned->new();
				$hpane->set_name('hpane');
				$hpane->set_gutter_position(13);
				$audience_window->add_widget($hpane);
				$hpane->add1(
					my $l1 =
						Curses::Toolkit::Widget::Label->new()->set_text('This is a naive label. Very naive')
						->set_name('label1'),
				);
				$hpane->add2(
					my $l2 =
						Curses::Toolkit::Widget::Label->new()->set_text('An other nonetheless naive label.Honest !')
						->set_name('label2'),
				);
				$audience_window->{theme} = Curses::Toolkit::Theme::Default::Color::Pink->new($audience_window);
				$audience_window->set_theme_property( title_width => 50 );
				$hpane->{theme} = Curses::Toolkit::Theme::Default::Color::Pink->new($hpane);
				$l1->{theme}    = Curses::Toolkit::Theme::Default::Color::Pink->new($l1);
				$l2->{theme}    = Curses::Toolkit::Theme::Default::Color::Pink->new($l2);
				$root->needs_redraw();
			}
		);

		$root->add_delay( $t->(1), sub { $set->("Mister Book, can you please resize and move the window ?\n") } );
		$root->add_delay( $t->(2), sub { $app->("Oh and, can you drag and drop the Paned seperation ?\n") } );
		$root->add_delay( $t->(3), sub { $set->("") } );

		$root->add_delay(
			$t->(5),
			sub {
				$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
				$set->("That's all folks\n");
			}
		);
		$root->add_delay(
			$t->(2),
			sub {
				$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
				$app->("I hope you likes what you saw.\n");
			}
		);
		$root->add_delay(
			$t->(5),
			sub {
				$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
				$set->("More information : https://github.com/dams/curses-toolkit/\n");
			}
		);
		if ( $m > 0 || $s > 0 ) {
			$root->add_delay(
				$t->(5),
				sub {
					$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
					$app->("\nThere is still $m:$s to waste\n");
				}
			);
			$root->add_delay(
				$t->(2),
				sub {
					$audience_window->set_coordinates( x1 => 3, y1 => 3, x2 => 40, y2 => 10 );
					$app->("So Book will dance for you. Book ?\n");
				}
			);

		}
	};

	$step1->();
	POE::Kernel->run();
}
