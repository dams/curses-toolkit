#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;

	local $| = 1;
	print STDERR "\n\n\n--- starting demo8 -----------------\n\n";

	my $root = Curses::Toolkit->init_root_window( clear => 0 )->add_window(
		my $window = Curses::Toolkit::Widget::Window->new()->set_name('main_window')->add_widget(
			my $border1 = Curses::Toolkit::Widget::Border->new()->set_name('border1')->add_widget(
				my $label1 = Curses::Toolkit::Widget::Label->new()->set_name('label1')->set_text('Some text')
			),
			)->set_coordinates(
			x1 => 0, y1 => 0,
			x2 => '10%',
			y2 => '50%',
			)
	)->render()->display();
	sleep 4;
}

