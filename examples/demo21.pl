#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;

sub main {

	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::VBox;
	use Curses::Toolkit::Widget::Entry;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::Label;

	my $root = POE::Component::Curses->spawn();


	my $window;
	$root->add_window(
		$window = Curses::Toolkit::Widget::Window->new()
		  ->set_name('window')
		  ->set_title("a title")
	);

	my $label1 = Curses::Toolkit::Widget::Label->new->set_text(' ');
	my $label2 = Curses::Toolkit::Widget::Label->new->set_text('You entered in the entry :');
	my $entry = Curses::Toolkit::Widget::Entry->new()
	  ->signal_connect(focus_changed => \&focus_changed, $label1)
	  ->signal_connect(content_changed => \&content_changed, $label2);

	$window->add_widget(
		my $vbox = Curses::Toolkit::Widget::VBox->new()
		  ->pack_end(Curses::Toolkit::Widget::Label
					     ->new
					     ->set_text("Please enter your name"),
					 { expand => 0 })
		  ->pack_end($entry,
					 { expand => 0 })
		  ->pack_end($label1,
					 { expand => 0 })
		  ->pack_end($label2,
					 { expand => 0 })
		  ->pack_end(Curses::Toolkit::Widget::Button->new_with_label('Exit')
					 ->signal_connect(clicked => sub { exit }),
					 { expand => 0 })
	);
	$window->set_coordinates(x1 => '15%',   y1 => '15%',
							 x2 => '85%',
							 y2 => '85%',
							);
	POE::Kernel->run();
}

my $count;
sub focus_changed {
	my ($event, $widget, $label) = @_;
	my $focus = $event->isa('Curses::Toolkit::Event::Focus::In') ? 'in' : 'out' ;
	$label->set_text("you just focused $focus of the entry");
	return;
}
sub content_changed {
	my ($event, $widget, $label) = @_;
	$label->set_text("Entry changed : [" . $widget->get_text . "]" );
	return;	
}
