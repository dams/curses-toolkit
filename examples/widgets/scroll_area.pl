#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";
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

	use Curses::Toolkit::Widget::ScrollArea;

	my $root = POE::Component::Curses->spawn();

    my $window = Curses::Toolkit::Widget::Window
                   ->new()
                   ->set_name('window2')
                   ->set_title("testing scroll area");

	$root->add_window( $window );

    $window->add_widget(
      Curses::Toolkit::Widget::ScrollArea->new
        ->add_widget(
          Curses::Toolkit::Widget::HBox->new
            ->pack_end(
              Curses::Toolkit::Widget::Border->new
                ->add_widget(
                  Curses::Toolkit::Widget::Label->new()
                    ->set_text("This is a quite long label. Actually, it is <b>very</b> long. How long can it be ? Not sure...")
                )
            )
            ->pack_end(
              Curses::Toolkit::Widget::Border->new
                ->add_widget(
                  Curses::Toolkit::Widget::Label->new()
                    ->set_text("THIS IS A QUITE LONG LABEL. ACTUALLY, IT IS <B>VERY</B> LONG. HOW LONG CAN IT BE ? NOT SURE...")
                )
            ),
        )
    );

	$window->set_coordinates(
		x1 => '0',   y1 => '0',
		x2 => '100%', y2 => '100%',
	);

	POE::Kernel->run();
}
