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

	$step1->();
	POE::Kernel->run();
}
