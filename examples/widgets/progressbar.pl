#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw{ $Bin };
use lib "$Bin/../../lib";
main() unless caller;

sub main {
	use POE::Component::Curses;

	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::HBox;
	use Curses::Toolkit::Widget::Button;
	use Curses::Toolkit::Widget::ProgressBar;

	my $root = POE::Component::Curses->spawn;


	my $window;
	$root->add_window(
		$window = Curses::Toolkit::Widget::Window->new()
		  ->set_name('window')
		  ->set_title("progress bar demo")
		  ->set_coordinates(x1 => 0, y1 => 0, x2 => '100%', y2 => '100%')
	);


        my $but1 = Curses::Toolkit::Widget::Button->new_with_label('-')->set_name('but1');
        my $but2 = Curses::Toolkit::Widget::Button->new_with_label('+')->set_name('but2');
        my $bar  = Curses::Toolkit::Widget::ProgressBar->new
		->set_maximum(10);

	my $hbox = Curses::Toolkit::Widget::HBox->new;
	$hbox->pack_end( $but1 );
	$hbox->pack_end( $bar, { expand => 1 } );
	$hbox->pack_end( $but2 );
	$window->add_widget($hbox);

	$but1->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_events => {
				'Curses::Toolkit::Event::Key' => sub {
					my ($event) = @_;
					$event->{type} eq 'stroke' or return 0;
					$event->{params}{key} eq ' ' or return 0;
				}
			},
			code => sub {
				$bar->set_position( $bar->get_position - 1 );
			},
		)
	);
	$but2->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_events => {
				'Curses::Toolkit::Event::Key' => sub {
					my ($event) = @_;
					$event->{type} eq 'stroke' or return 0;
					$event->{params}{key} eq ' ' or return 0;
				}
			},
			code => sub {
				$bar->set_position( $bar->get_position + 1 );
			},
		)
	);

	POE::Kernel->run();
}