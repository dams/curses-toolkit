#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::HBox;

	local $| = 1;
	print STDERR "\n\n\n--------------------\n\n";

	my $root = Curses::Toolkit->init_root_window( clear => 0 )->add_window(
		my $window = Curses::Toolkit::Widget::Window->new()->set_name('main_window')->add_widget(
			my $border1 = Curses::Toolkit::Widget::Border->new()->set_name('border1')->add_widget(
				my $hbox1 = Curses::Toolkit::Widget::HBox->new()->pack_end(
					my $border2 = Curses::Toolkit::Widget::Border->new()->set_name('border2')->add_widget(
						my $label1 =
							Curses::Toolkit::Widget::Label->new()->set_name('label1')->set_text('expanding border1')

							#                         ->set_wrap_mode('never')
					),
					{ expand => 1 }
					)->pack_end(
					my $border3 = Curses::Toolkit::Widget::Border->new()->set_name('border3')->add_widget(
						my $label31 =
							Curses::Toolkit::Widget::Label->new()->set_name('label31')->set_text('expanding border')
					),
					{ expand => 1 }
					)
			)
			)->set_coordinates(
			x1 => 0,
			y1 => 0,
			x2 => 40,
			y2 => 30
			)
	)->render()->display();

	sleep 2;

	use Time::HiRes qw(usleep);
	use Curses::Toolkit::Object::Coordinates;
	while (1) {
		foreach ( 1 .. 15 ) {
			usleep(80000);
			$window->set_coordinates( $window->get_coordinates() + { y2 => 1, x2 => 2 } );
			$root->render()->display();
		}
		foreach ( 1 .. 15 ) {
			usleep(80000);
			$window->set_coordinates( $window->get_coordinates() + { y2 => -1, x2 => -2 } );
			$root->render()->display();
		}
	}

}
