#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	my $root = Curses::Toolkit->init_root_window(clear => 0);

	use Curses::Toolkit::Widget::Window;
	my $window = Curses::Toolkit::Widget::Window->new();
	$window->set_coordinates(x1 => 2, y1 => 5,
							 x2 => 7, y2 => 7,
							);
	$root->add_window($window);
	$root->render();
	$root->display();
	sleep 5;
}
