#!/usr/bin/perl

use strict;
use warnings;

use lib qw(../lib);
main() unless caller;


use Benchmark;

sub main {

	use Curses::Toolkit;
	use Curses::Toolkit::Widget::Window;
	use Curses::Toolkit::Widget::Border;
	use Curses::Toolkit::Widget::Label;

	local $| = 1;

	my $root = Curses::Toolkit->init_root_window( clear => 0 )->add_window(
		my $window = Curses::Toolkit::Widget::Window->new()->set_name('main_window')
          ->set_coordinates(
			x1 => 0,
			y1 => 0,
			x2 => 15,
			y2 => 20
		  )
	)->render()->display();

# start timer

my $start = new Benchmark;

	use Curses::Toolkit::Object::Coordinates;
    my $i = 30;
	while ($i--) {
		foreach ( 1 .. 10 ) {
			$window->set_coordinates( $window->get_coordinates() + { x2 => 3 } );
			$root->render()->display();
		}
		foreach ( 1 .. 10 ) {
			$window->set_coordinates( $window->get_coordinates() + { x2 => -3 } );
			$root->render()->display();
		}
	}


# end timer
my $end = new Benchmark;

# calculate difference
my $diff = timediff($end, $start);

# report
print STDERR "Time taken was ", timestr($diff, 'all'), " seconds";

}
