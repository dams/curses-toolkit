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

	local $| = 1;
	print STDERR "\n\n\n--- starting demo7 -----------------\n\n";

	$root->add_window(
        my $window = Curses::Toolkit::Widget::Window
          ->new()
          ->set_name('main_window')
          ->add_widget(
            my $border1 = Curses::Toolkit::Widget::Border
              ->new()
              ->set_name('border1')
              ->add_widget(
			    my $label1 = Curses::Toolkit::Widget::Label
				  ->new()
				  ->set_name('label1')
                  ->set_text('This demonstrates the use of Curses::Toolkit used with its POE Event Loop : POE::Component::Curses. Keyboard events and window resizing are supported')
              ),
		  )
          ->set_coordinates(x1 => 0,   y1 => 0,
                            x2 => '100%',
							y2 => '100%',
						   )
      );
#      ->render()
#      ->display();
	POE::Kernel->run();
}

