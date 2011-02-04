#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(../../../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;

	my $root = Curses::Toolkit->init_root_window(  )->add_window(
		my $window = Curses::Toolkit::Widget::Window->new()->set_name('main_window')->set_coordinates(
			x1 => 0,  y1 => 0,
			x2 => 40, y2 => 20
			)->add_widget( my $border1 = Curses::Toolkit::Widget::Border->new()->set_name('border1') )
	)->render()->display();

	# 	my $root = Curses::Toolkit
	# 	  ->init_root_window(clear => 0);

	# 	my $window = Curses::Toolkit::Widget::Window->new();

	# 	my $border = Curses::Toolkit::Widget::Border->new();
	# 	$border->set_name('border1');

	# 	$root->add_window($window);

	# 	$window->set_name('main_window');
	# 	$window->set_coordinates(x1 => 0,   y1 => 0,
	# 							 x2 => 40,  y2 => 20);

	# 	$window->add_widget( $border );

	# 	$root->render();
	# 	$root->display();

	sleep 3;

	#	use Time::HiRes qw(usleep);
	#	use Curses::Toolkit::Object::Coordinates;
	#	while (1) {
	#		foreach (1..10) {
	#			usleep(40000);
	# 			$window->set_coordinates($window->get_coordinates() +
	# 									 { x1 => 0, y1 => 0,
	# 									   x2 => 2, y2 => -1, }
	# 									);
	#			$root
	#			  ->render()
	#				->display();
	# 		}
	# 		foreach (1..10) {
	# 			usleep(40000);
	# 			$window->set_coordinates($window->get_coordinates() +
	# 									 { x1 => 0,  y1 => 0,
	# 									   x2 => -2, y2 => 1, }
	# 									);
	# 			$root
	# 			  ->render()
	# 				->display();
	# 		}
	# 	}

	# 	sleep 20;

}
