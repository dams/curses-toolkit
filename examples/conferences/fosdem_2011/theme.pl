#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

main() unless caller;

sub main {
    use POE::Component::Curses;

    use Curses::Toolkit::Widget::Window;
    use Curses::Toolkit::Widget::Label;
    use Curses::Toolkit::Widget::VBox;
    use Curses::Toolkit::Widget::HBox;
    use Curses::Toolkit::Widget::Button;

    use Curses::Toolkit::Theme::Default::Color::BlueWhite;
    my $root = POE::Component::Curses->spawn( args => { theme_name => 'Curses::Toolkit::Theme::Default::Color::BlueWhite' } );
    my $window1 =
      Curses::Toolkit::Widget::Window->new->set_name('window')->set_title("label tests 1")
          ->set_coordinates( x1 => 5, y1 => 5, x2 => 75, y2 => 21 );
    $root->add_window($window1);
    $window1->add_widget(
        Curses::Toolkit::Widget::VBox->new()->pack_end(
            Curses::Toolkit::Widget::Label->new->set_justify('center')->set_text("Click here to change the theme"),
            { expand => 1, fill => 0 }
        )->pack_end(
            my $button01 =
                Curses::Toolkit::Widget::Button->new_with_label('Change'),
            { expand => 1, fill => 1 }
        )
    );
    POE::Kernel->run();
}
