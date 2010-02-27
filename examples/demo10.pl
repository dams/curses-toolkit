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
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;

	my $root = POE::Component::Curses->spawn();

	#	my $root = Curses::Toolkit->init_root_window();

	local $| = 1;
	print STDERR "\n\n\n--- starting demo9 -----------------\n\n";

	$root->add_window(
		Curses::Toolkit::Widget::Window->new()->add_widget(
			Curses::Toolkit::Widget::Border->new()->add_widget(
				Curses::Toolkit::Widget::HBox->new()->pack_end(
					Curses::Toolkit::Widget::Border->new()
						->add_widget( Curses::Toolkit::Widget::Label->new()->set_text('LABEL1') ),
					{ expand => 1 }
					)->pack_end(
					Curses::Toolkit::Widget::VBox->new()->pack_end(
						Curses::Toolkit::Widget::Border->new()
							->add_widget( Curses::Toolkit::Widget::Label->new()->set_text('LABEL2') ),
						{ expand => 0 }
					),
					{ expand => 0 }
					)





			)
			)->set_coordinates(
			x1 => 0,
			y1 => 0,
			x2 => '100%',
			y2 => '100%',
			)
	);

	#$root
	#      ->render()
	#      ->display();
	#sleep 5;
	#	print STDERR Dumper($root); use Data::Dumper;
	POE::Kernel->run();
}

