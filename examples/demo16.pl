#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Entry;

	use Curses::Toolkit::Widget::Label;

	my $root = POE::Component::Curses->spawn();
#	my $root = Curses::Toolkit->init_root_window();

	local $| = 1;
	print STDERR "\n\n\n--- starting demo16 -----------------\n\n";

	my $window = Curses::Toolkit::Widget::Window->new();
	$root->add_window($window);
	$window->set_title("The usually long title...");
#	$window->set_theme_property(title_position => 'center');

	my $vbox = Curses::Toolkit::Widget::VBox->new();
	$window->add_widget($vbox);
	$vbox->pack_end( Curses::Toolkit::Widget::HBox->new()
					 ->pack_end(
								my $button01 = Curses::Toolkit::Widget::Button
								->new_with_label('This is a button !')
								->set_name('button1'),
								{ expand => 1 }
							   )
					 ->pack_end(
								Curses::Toolkit::Widget::Entry
								->new_with_text('Test')
								->set_name('entry1'),
								{ expand => 1 }
							   ),
					 { expand => 0 }
				   );
	$vbox->pack_end(
					Curses::Toolkit::Widget::Border->new()
					->add_widget(
								 Curses::Toolkit::Widget::Label->new()
								 ->set_text('expanding border with a label (this text) in it')
								),
					{ expand => 1 }
				   );
	$vbox->pack_end(
					Curses::Toolkit::Widget::HBox->new()
					->pack_end(
							   my $button1 = Curses::Toolkit::Widget::Button
							   ->new_with_label('This button is there!')
							   ->set_name('button1'),
							   { expand => 0 }
							  )
					->pack_end(
							   my $button2 = Curses::Toolkit::Widget::Button
							   ->new_with_label('Yet Another Button !')
							   ->set_name('button2'),
							   { expand => 0 }
							  ),
					{ expand => 0 }
				   );
	$window->set_coordinates(x1 => 0,   y1 => 0,
							 x2 => '100%',
							 y2 => '100%',
							);

	$button1->set_focus(1);
#	$button1->register_event( type => keyboard

# $root
#       ->render()
#       ->display();
# sleep 5;
	POE::Kernel->run();
}

