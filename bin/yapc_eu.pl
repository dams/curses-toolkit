#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

use POE;

sub main {

	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Entry;
	use Curses::Toolkit::Widget::HPane;
	use Curses::Toolkit::Widget::Label;


	my $root = POE::Component::Curses->spawn( args => { theme_name => 'Curses::Toolkit::Theme::Default' } );


#1 ############# time label

my ($step1, $step2);
$step1 = sub {
	my $move_label = 0;

	my $time_window = Curses::Toolkit::Widget::Window->new();
	$time_window->set_name('time remaining'),
	$root->add_window($time_window);
	$time_window->set_theme_property(border_width => 0);

	my $time_label = Curses::Toolkit::Widget::Label->new()
	  ->set_text('5:00')
	  ->set_name('label1');
	$time_window->add_widget($time_label);

	use Time::HiRes qw(time);
	POE::Session->create(
		inline_states => {
			_start => sub {
				$_[HEAP]->{min} = 5;
				$_[HEAP]->{sec} = 0;
				$_[HEAP]->{next_alarm_time} = int(time()) + 1;
				$_[KERNEL]->alarm(tick => $_[HEAP]->{next_alarm_time});
				$_[KERNEL]->delay_add( move_label => 1/10 );
			},
			tick => sub {
				if ($_[HEAP]->{sec} == 0) {
					if ($_[HEAP]->{min} == 0) {
						print STDERR "timer elapsed\n";
					} else {
						$_[HEAP]->{min}--;
						$_[HEAP]->{sec} = 59;
					}
				} else {
					$_[HEAP]->{sec}--;
				}
				$time_label->set_text($_[HEAP]->{min} . ':' . ($_[HEAP]->{sec} < 10 ? '0' : '') . $_[HEAP]->{sec});
				$root->needs_redraw();
				$_[HEAP]->{next_alarm_time}++;
				$_[KERNEL]->alarm(tick => $_[HEAP]->{next_alarm_time});
			},
			move_label => sub {
				my ($screen_h, $screen_w);
				if ($move_label) {
					$root->{curses_handler}->getmaxyx($screen_h, $screen_w);
					my $c = $time_label->get_coordinates();
					my $wc = $time_window->get_coordinates();
					my $nr = 0;
					int $c->x1() < $screen_w - 4 and $wc->set(x1 => $wc->x1() + 1,
															  x2 => $wc->x2() + 1
															 ), $nr = 1;
					int $c->x1() > $screen_w - 4 and $wc->set(x1 => $wc->x1() - 1,
															  x2 => $wc->x2() - 1
															 ), $nr = 1;
					int $c->y1() < 0 and $wc->set(y1 => $wc->y1() + 1,
												  y2 => $wc->x2() + 1
												 ), $nr = 1;
					int $c->y1() > 0 and $wc->set(y1 => $wc->y1() - 1,
												  y2 => $wc->x2() - 1
												 ), $nr = 1;
					$nr == 1 and $time_window->set_coordinates($wc);
					$nr == 1 and $root->needs_redraw();
				}
				$_[KERNEL]->delay_add( move_label => 1/6 );
			},
		},
	);

	my ($screen_h, $screen_w);
	$root->{curses_handler}->getmaxyx($screen_h, $screen_w);

	$time_window->set_coordinates(x1 => $screen_w/2 - 2, y1 => $screen_h/2,
								  x2 => $screen_w/2 + 2, y2 => $screen_h/2 + 1,
								 );

	$root->add_window(
		my $OK_window = Curses::Toolkit::Widget::Window->new()
		  ->set_theme_property(border_width => 0)
		  ->add_widget(
		    my $button1 = Curses::Toolkit::Widget::Button
		      ->new_with_label('Hit space when you are ready to start!')
			  ->add_event_listener(
			    Curses::Toolkit::EventListener->new(
				  accepted_event_class => 'Curses::Toolkit::Event::Key',
				  conditional_code => sub { 
					my ($event) = @_;
					$event->{type} eq 'stroke' or return 0;
					$event->{params}{key} eq ' ' or return 0;
				  },
				  code => sub {
					  my ($event, $button) = @_;
					  $move_label = 1;
					  $button->get_parent()->remove_widget();
					  POE::Session->create(
						inline_states => {
						  _start => sub {
							$poe_kernel->delay_add( start_step2 => 3 );
						  },
						  start_step2 => sub { $step2->(); },
						}
					  );
				  },
			    )
		      )
	      )
		  ->set_coordinates( x1 => ($screen_w - 40)/2, y1 => $screen_h/2+1,
							 x2 => ($screen_w + 45)/2, y2 => $screen_h/2 + 2,
		  )
	);
	$OK_window->set_theme_property(border_width => 0);
	$button1->set_focus(1);
};

$step2 = sub {
	$root->add_window(
	  my $window = Curses::Toolkit::Widget::Window->new()
	    ->set_title("This is a long title")
	);
	$window->set_theme_property(border_width => 0);
	$window->set_coordinates( x1 => 3, y1 => '55%',
#							  x2 => 50, y2 => 80,
							  x2 => '100%', y2 => '100%',
							);
	$window->add_widget(my $label = Curses::Toolkit::Widget::Label->new()
						->set_text("Hello !                                                                           .\n                                                                           .\n                                                                           .\n                                                                           .\n                                                                           .\n\n\n")
					   );
	my $app = sub { $label->set_text($label->get_text() . $_[0])};
	my $set = sub { $label->set_text($_[0])};
	my $o = 0;
	my $t = sub { $o += ($_[0]/1); return $o; };
# 	$root->add_delay($t->(5), sub { $set->("My name is Damien Krotkine\n") });
# 	$root->add_delay($t->(3), sub { $app->("I'm also known as 'dams'\n") });
# 	$root->add_delay($t->(3), sub { $set->("\n") });
# 	$root->add_delay($t->(3), sub { $set->("I am not the funny guy which is standing on the scene.\n") });
# 	$root->add_delay($t->(5), sub { $app->("The funny guy is called BooK, and I'm sure you ALL know him.") });
# 	$root->add_delay($t->(5), sub { $set->("I couldn't make it to the YAPC::EU this year\nso I asked Book to give this talk for me !") });
# 	$root->add_delay($t->(5), sub { $set->("") });
# 	$root->add_delay($t->(5), sub { $set->("OK. So what is this talk about ?\n") });
# 	$root->add_delay($t->(5), sub { $set->("this talk is about : \n") });
# 	$root->add_delay($t->(5), sub { $app->("   Curses::Toolkit   !") });
# 	$root->add_delay($t->(5), sub { $set->("Curses::Toolkit is a\n") });
# 	$root->add_delay($t->(2), sub { $app->("modern ") });
# 	$root->add_delay($t->(2), sub { $app->("POE based ") });
# 	$root->add_delay($t->(2), sub { $app->("object oriented ") });
# 	$root->add_delay($t->(2), sub { $app->("widget oriented ") });
# 	$root->add_delay($t->(2), sub { $app->("GTK inspired ") });
# 	$root->add_delay($t->(2), sub { $app->("curses ") });
# 	$root->add_delay($t->(2), sub { $app->("toolkit !\n") });
# 	$root->add_delay($t->(5), sub { $set->("") });
#	$root->add_delay($t->(5), sub { $set->("Book is kind enough to do things for me\n") });
#	$root->add_delay($t->(2), sub { $app->("So I'll use that opportunity to make him do stupid things :)\n") });
#	$root->add_delay($t->(5), sub { $app->("\nOh and you will have to participate too !\n") });
#	$root->add_delay($t->(2), sub { $app->("And while doing so I'll demonstrate some features of Curses::Toolkit\n") });
#	$root->add_delay($t->(5), sub { $set->("") });

	my $audience_window;
	my $audience_label;
	$root->add_delay($t->(2), sub { $set->("Let's start with a window\n");});
	$root->add_delay($t->(2), sub { 
									$root->add_window(
													  $audience_window = Curses::Toolkit::Widget::Window->new()
													 );
									$audience_window->set_coordinates( x1 => 3, y1 => 3,
																	   x2 => 40, y2 => 10,
																	 );
									$audience_window->add_widget(
																 $audience_label = Curses::Toolkit::Widget::Label->new()
																 ->set_text("Wow this is a cool window !")
																);

								});
	$root->add_delay($t->(2), sub { $app->("oh it's new and shiny !\n") });
	$root->add_delay($t->(2), sub { $set->("The good thing about Curses::Toolkit is that\nyou don't have to mess with cordinates, the module handles it for you") });
	$root->add_delay($t->(5), sub { $set->("For example, I can move and resize the window") });
					  
#	my $move_audience_window = 0;
	my $move_audience_window_sub;
	my $loop = 10;
	$move_audience_window_sub = sub { my $wc = $audience_window->get_coordinates(); 
									  $audience_window->set_coordinates(x1 => $wc->x1() + 1);
									  $loop-- and 	$root->add_delay(1/3, $move_audience_window_sub);
								  };
	$root->add_delay($t->(2), $move_audience_window_sub);
	
};

	$step1->();
	POE::Kernel->run();
}
