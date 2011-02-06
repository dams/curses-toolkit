#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label);

main() unless caller;

sub main {
    use POE::Component::Curses;

    use Curses::Toolkit::Widget::Window;
    use Curses::Toolkit::Widget::Label;
    use Curses::Toolkit::Widget::Border;

    my $root = POE::Component::Curses->spawn;
    my $window =
      Window->new->set_name('window')->set_title("window")
            ->set_coordinates( x1 => 5, y1 => 5, width => 20, height => 5 );
    $root->add_window($window);

    my $label = Label->new->set_text('Hello World !');
    $window->add_widget($label);
    POE::Kernel->run();
}
