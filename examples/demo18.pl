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


	$root->add_window( my $window1 = Curses::Toolkit::Widget::Window->new()->set_name('window')->set_title("a title") );

	$window1->add_widget(
		my $hpaned = Curses::Toolkit::Widget::HPaned->new()->set_name('hpaned')->set_gutter_position(50)->add1(
			my $button1 = Curses::Toolkit::Widget::Button->new_with_label('This is a button'),
			)->add2( my $button2 = Curses::Toolkit::Widget::Button->new_with_label('This is an other button') )
	);
	$window1->set_coordinates(
		x1 => '10%', y1 => '10%',
		x2 => '80%',
		y2 => '80%',
	);


	$root->add_window( my $window2 =
			Curses::Toolkit::Widget::Window->new()->set_name('window2')->set_title("a title2") );

	my $button3 = Curses::Toolkit::Widget::Button->new_with_label('This is a button 3');
	my $button4 = Curses::Toolkit::Widget::Button->new_with_label('This is a button 4');
	$window2->add_widget( my $vbox =
			Curses::Toolkit::Widget::VBox->new()->pack_end( $button3, { expand => 0 } )
			->pack_end( $button4, { expand => 0 } ) );
	$window2->set_coordinates(
		x1 => '15%', y1 => '15%',
		x2 => '85%',
		y2 => '85%',
	);
	$button3->set_focus(1);
	POE::Kernel->run();
}
