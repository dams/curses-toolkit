#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use POE::Component::Curses;
	use Curses::Toolkit::Widget::Window;

	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;

	my $root = POE::Component::Curses->spawn();

	$root->add_window(my $win1 = Curses::Toolkit::Widget::Window->new());

	$win1->add_widget(
      Curses::Toolkit::Widget::Border
	    ->new()
		->add_widget(
		  Curses::Toolkit::Widget::Label
		    ->new()
            ->set_text("window 1")
	  )
	);

	$win1->set_coordinates(x1 => 0,   y1 => 0,
						   x2 => '40%',
						   y2 => '40%',
						  );


	$root->add_window(my $win2 = Curses::Toolkit::Widget::Window->new());

	$win2->add_widget(
      Curses::Toolkit::Widget::Border
	    ->new()
		->add_widget(
		  Curses::Toolkit::Widget::Label
		    ->new()
            ->set_text("window 2")
	  )
	);

	$win2->set_coordinates(x1 => '15%',   y1 => '15%',
						   x2 => '45%',
						   y2 => '45%',
						  );

	POE::Kernel->run();
}

