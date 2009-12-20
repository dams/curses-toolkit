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


	my $window;
	$root->add_window(
		$window = Curses::Toolkit::Widget::Window->new()
		  ->set_name('window')
		  ->set_title("a title")
	);

	my $label = Curses::Toolkit::Widget::Label->new->set_text("This is <span weight='underline'>underlined text <span weight='bold'>very bold</span> chunk </span> chunk");
	$window->add_widget(
		my $vbox = Curses::Toolkit::Widget::VBox->new()
		  ->pack_end($label, { expand => 0 })
	);
	$window->set_coordinates(x1 => '15%',   y1 => '15%',
							 x2 => '85%',
							 y2 => '85%',
							);
	POE::Kernel->run();
}
