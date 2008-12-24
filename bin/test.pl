#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;

	my $root = Curses::Toolkit
	  ->init_root_window(clear => 0)
	  ->add_window(
	    my $window = Curses::Toolkit::Widget::Window
		  ->new()
		  ->set_name('main_window')
		  ->set_coordinates(x1 => 2,  y1 => 5,
							x2 => 60, y2 => 30)
		  ->add_widget(
			Curses::Toolkit::Widget::Border
			  ->new()
		  )
	  )
	  ->render()
	  ->display();
	sleep 50;
}
