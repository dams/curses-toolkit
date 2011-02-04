#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

open STDERR, '>>/dev/null';

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label VBox HBox Button);
use relative -to      => "Curses::Toolkit::Theme::Default::Color",
             -aliased => qw(BlueWhite Yellow Pink);
use relative -to      => "Curses::Toolkit::Theme",
             -aliased => qw(Default);

main() unless caller;

sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn( args => { theme_name => BlueWhite } );

    foreach my $i (1..5) {
        $root->add_window(
            Window->new->set_title("Window $i")
                  ->set_coordinates( x1 => 2 + 12 * $i, y1 => 1 + 2 * $i,
                                     width => 25, height => 10 )
                  ->add_widget(
                      VBox->new()->pack_end(
                          Label->new->set_justify('center')->set_text("This is window $i."),
                          { expand => 1 }
                      )->pack_end(
                          Button->new_with_label('OK'),
                          { expand => 0 }
                      )
                  )
        );
    }

    POE::Kernel->run();
}
