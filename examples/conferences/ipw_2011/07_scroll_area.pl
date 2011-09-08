#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label HBox VBox Border ScrollArea);

main() unless caller;

sub main {

	use POE::Component::Curses;

	my $root = POE::Component::Curses->spawn();

    my $window = Curses::Toolkit::Widget::Window->new()
      ->set_name('window')
#      ->set_title("testing scroll area 1234567890 1234567890")
      ->set_title("testing scroll area")
      ->set_coordinates( x1 => 5, y1 => 5, width => 40, height => 7 );

	$root->add_window( $window );

    $window->add_widget(
      my $s = Curses::Toolkit::Widget::ScrollArea->new
        ->set_name('scroll_area')
        ->add_widget(
            Curses::Toolkit::Widget::Border->new
              ->set_name('border')
              ->add_widget(
                    Label->new()
                      ->set_name('label')
                      ->set_text(
"blah blah blah. this is a paragraph. It's cool, but it's on one line. Isn't it ?

Let's try an other paragraph

And here, line 1
Then line 2
And a third line here."),
                # VBox->new->pack_end(
                #     Label->new()
                #       ->set_text("line 1"),
                #     { expand => 0 },
                # )->pack_end(
                #     Label->new()
                #       ->set_text("line 2"),
                #     { expand => 0 },
                # )->pack_end(
                #     Label->new()
                #       ->set_text("line 3 : very very long line 1234567890 1234567890 1234567890 1234567890"),
                #     { expand => 0 },
                # )->pack_end(
                #     Label->new()
                #       ->set_text("line 4"),
                #     { expand => 0 },
                # )
              )
        )
    );


    # my $root_window = $window->get_root_window();
    # my $delay = 1;
    # my $counter = 0;
    # my $f;
    # $f = sub { $window->set_title(" PLOP " . $counter++);
    #            $s->{scroll_y}-=30;
    #            $window->rebuild_all_coordinates();
    #            $window->needs_redraw();
    #            $root_window->add_delay( $delay, $f );};
    # $root_window->add_delay( $delay, $f );


	POE::Kernel->run();
}
