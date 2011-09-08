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

Curses::Toolkit->init_root_window()->add_window(
    Window->new()->add_widget(
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

sleep;

}

sub border_with_label { Border->new()->add_widget(Label->new()->set_text(shift)) }

