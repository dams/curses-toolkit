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
	use Curses::Toolkit::Widget::HPaned;
	use Curses::Toolkit::Widget::VPaned;
	use Curses::Toolkit::Widget::Label;

	my $root = POE::Component::Curses->spawn();

	local $| = 1;
	print STDERR "\n\n\n--- starting demo18 -----------------\n\n";

	my $window = Curses::Toolkit::Widget::Window->new();
	$window->set_name('window'),
	$root->add_window($window);
	$window->set_title("a title");

	my $hpaned = Curses::Toolkit::Widget::HPaned->new();
	$hpaned->set_name('hpaned'),
	$hpaned->set_gutter_position(50);
	$window->add_widget($hpaned);
	$hpaned->add1(Curses::Toolkit::Widget::Button->new_with_label('This is a button'),
				 );
	$hpaned->add2(Curses::Toolkit::Widget::Label->new()
				  ->set_text('An other nonetheless naive label.Honest !')
				  ->set_name('label2'),
				 );
	$window->set_coordinates(x1 => 0,   y1 => 0,
							 x2 => '100%',
							 y2 => '100%',
							);
	POE::Kernel->run();
}
