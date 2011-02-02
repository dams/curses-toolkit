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
    use Curses::Toolkit::Widget::Border;

    my $root = POE::Component::Curses->spawn;
    my $window1 =
      Curses::Toolkit::Widget::Window->new->set_name('window')->set_title("label tests 1")
          ->set_coordinates( x1 => 0, y1 => 0, x2 => '100%', y2 => 30 );
    $root->add_window($window1);
    POE::Kernel->run();
}
