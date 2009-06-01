#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use POE::Component::Curses;
#	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;
	use Curses::Toolkit::Widget::Button;

	my $root = POE::Component::Curses->spawn();

#	my $root = Curses::Toolkit->init_root_window();

	local $| = 1;
	print STDERR "\n\n\n--- starting demo9 -----------------\n\n";

	$root->add_window(
        my $window = Curses::Toolkit::Widget::Window
          ->new()
          ->set_name('main_window')
          ->add_widget(
            my $border1 = Curses::Toolkit::Widget::Border
              ->new()
              ->set_name('border1')
              ->add_widget(
			    my $button1 = Curses::Toolkit::Widget::Button
				  ->new_with_label('This button is focused !')
				  ->set_name('button1')
              ),
		  )
          ->set_coordinates(x1 => 0,   y1 => 0,
                            x2 => '100%',
							y2 => '100%',
						   )
      );
	$button1->set_focus(1);
#	$button1->register_event( type => keyboard

#$root
#      ->render()
#      ->display();
#sleep 5;
	POE::Kernel->run();
}

