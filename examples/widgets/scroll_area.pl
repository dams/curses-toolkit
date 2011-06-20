#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label HBox Border ScrollArea);

main() unless caller;

sub main {

	use POE::Component::Curses;

	my $root = POE::Component::Curses->spawn();

    my $window = Curses::Toolkit::Widget::Window->new()
      ->set_name('window')
      ->set_title("testing scroll area")
      ->set_coordinates( x1 => 5, y1 => 5, width => 40, height => 7 );

	$root->add_window( $window );

    $window->add_widget(
      Curses::Toolkit::Widget::ScrollArea->new
        ->add_widget(
            Curses::Toolkit::Widget::Border->new
              ->add_widget(
                Curses::Toolkit::Widget::Label->new()
                  ->set_text("This is a quite long label. Actually, it is <b>very</b> long. How long can it be ? Not sure...")
              )
        )
    );

	POE::Kernel->run();
}
