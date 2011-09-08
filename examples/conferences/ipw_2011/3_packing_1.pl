#!/usr/bin/env perl

use strict;
use warnings;

use lib qw(../../../lib);

use Curses::Toolkit;
use Curses::Toolkit::Widget::Window qw(:all);
use Curses::Toolkit::Widget::Border qw(:all);
use Curses::Toolkit::Widget::Label qw(:all);
use Curses::Toolkit::Widget::VBox qw(:all);
use Curses::Toolkit::Widget::HBox qw(:all);

main() unless caller;

sub main {

my $root = Curses::Toolkit->init_root_window()->add_window(
    my $window = Window->new()->add_widget(
        VBox->new()
          ->pack_end(border_with_label('non-expanding border but a long label that hopefully wraps'))
          ->pack_end(
              HBox->new()
                ->pack_end( border_with_label('expanding border'), { expand => 1 } )
                ->pack_end( border_with_label('expanding border'), { expand => 1 } ),
              { expand => 1 })
          ->pack_end(
              HBox->new()
                ->pack_end( border_with_label('expanding border with fill'), { expand => 1, fill => 1 } )
                ->pack_end( border_with_label('expanding border with fill'), { expand => 1, fill => 1 } ),
              { expand => 1})
          ->pack_end(border_with_label('expanding border'),{ expand => 1 })
          ->pack_end(border_with_label('non expanding border'))
        )
    ->set_coordinates(
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
#			usleep(80000);
			$window->set_coordinates( $window->get_coordinates() + { y2 => 1, x2 => 2 } );
			$root->render()->display();
		}
		foreach ( 1 .. 15 ) {
#			usleep(80000);
			$window->set_coordinates( $window->get_coordinates() + { y2 => -1, x2 => -2 } );
			$root->render()->display();
		}
	}

}

sub border_with_label { Border->new()->add_widget(Label->new()->set_text(shift)) }


