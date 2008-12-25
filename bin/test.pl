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
		  ->set_coordinates(x1 => 0,   y1 => 0,
							x2 => 14,  y2 => 7)
		  ->add_widget(
			my $border1 = Curses::Toolkit::Widget::Border
			  ->new()
		      ->set_name('border1')
 			  ->add_widget(
 				my $border2 = Curses::Toolkit::Widget::Border
 				  ->new()
 				  ->set_name('border2')
 			      ->add_widget(
 				    my $border3 = Curses::Toolkit::Widget::Border
 				      ->new()
 				      ->set_name('border3')
 			    )
 			  )
		  )
	  )
	  ->render()
	  ->display();
	sleep 2;
	$window->set_coordinates(x1 => 1,  y1 => 1,
							 x2 => 15, y2 => 8,
							);
	$root
	  ->render()
	  ->display();

	sleep 20;

}
