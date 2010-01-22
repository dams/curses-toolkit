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

#	my $label = Curses::Toolkit::Widget::Label->new->set_text("<b>AAAAA BBBBB CCCCC DDDDD EEEEE FFFFF GGGGG</b>");
 	my $label = Curses::Toolkit::Widget::Label->new->set_text("This is <span weight='underline'>underlined text <span weight='bold'>underlined + bold</span> chunk </span> chunk");
 	my $label2 = Curses::Toolkit::Widget::Label->new->set_text("This is <span fgcolor='blue'>in blue, <span bgcolor='red'>red background </span> and blue again</span> chunk");
 	my $label3 = Curses::Toolkit::Widget::Label->new->set_text("This is a <span weight='bold'>bold <span weight='normal'>then normal</span> then back to bold</span> chunk");
	$window->add_widget(
		my $vbox = Curses::Toolkit::Widget::VBox->new()
		  ->pack_end($label, { expand => 0 })
		  ->pack_end($label2, { expand => 0 })
		  ->pack_end($label3, { expand => 0 })
	);
	$window->set_coordinates(x1 => '15%',   y1 => '15%',
							 x2 => '85%',
							 y2 => '85%',
							);
	POE::Kernel->run();
}
