#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../../../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;

	local $| = 1;
	open STDERR, '/dev/null';

	# 	my $root = Curses::Toolkit
	# 	  ->init_root_window(clear => 0)
	# 	  ->add_window(
	# 	    my $window = Curses::Toolkit::Widget::Window
	# 		  ->new()
	# 		  ->set_name('main_window')
	# 		  ->set_coordinates(x1 => 0,   y1 => 0,
	# 							x2 => 40,  y2 => 20)
	# 		  ->add_widget(
	# 			my $label1 = Curses::Toolkit::Widget::Label
	# 			->new()
	# 			->set_name('label')
	# 			->set_text('This is just a test with 8 words')
	# 		  )
	# 		)
	# 	  ->render()
	# 	  ->display();


	my $root = Curses::Toolkit->init_root_window( clear => 0 )->add_window(
		my $window = Curses::Toolkit::Widget::Window->new()->set_name('main_window')->add_widget(
			my $border1 = Curses::Toolkit::Widget::Border->new()->set_name('border1')->add_widget(
				my $border2 = Curses::Toolkit::Widget::Border->new()->set_name('border2')->add_widget(
					my $border3 = Curses::Toolkit::Widget::Border->new()->set_name('border3')->add_widget(
						my $label1 = Curses::Toolkit::Widget::Label->new()
							->set_text('This is just a test of a left justified label wrapped within 3 borders')

							#						->set_justify('left')
					)
				)
			)
			)->set_coordinates(
			x1 => 0,
			y1 => 0,
			x2 => 15,
			y2 => 20
			)

	)->render()->display();

	sleep 1;
	$label1->set_justify('center');
	$root->render()->display();
	sleep 2;
	$label1->set_justify('right');
	$root->render()->display();
	sleep 2;
	$label1->set_justify('center');
	$root->render()->display();
	sleep 2;
	$label1->set_justify('left');
	$root->render()->display();
	sleep 2;

	use Time::HiRes qw(usleep);
	use Curses::Toolkit::Object::Coordinates;
	while (1) {
		foreach ( 1 .. 10 ) {
			usleep(60000);
			$window->set_coordinates( $window->get_coordinates() + { x2 => 3 } );
			$root->render()->display();
		}
		foreach ( 1 .. 10 ) {
			usleep(60000);
			$window->set_coordinates( $window->get_coordinates() + { x2 => -3 } );
			$root->render()->display();
		}
	}

}
