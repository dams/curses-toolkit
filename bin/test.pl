#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;

print STDERR "\n";
	my $root = Curses::Toolkit
	  ->init_root_window(clear => 0)
	  ->add_window(
	    my $window = Curses::Toolkit::Widget::Window
		  ->new()
		  ->set_name('main_window')
		  ->set_coordinates(x1 => 1,  y1 => 1,
							x2 => 20,  y2 => 20)
		  ->add_widget(
			Curses::Toolkit::Widget::Border
			  ->new()
		      ->set_name('border1')
 			  ->add_widget(
 				Curses::Toolkit::Widget::Border
 				  ->new()
 				  ->set_name('border2')
 			  )
		  )
	  )
	  ->render()
	  ->display();
	sleep 50;
}
