#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib qw(../../../lib);

open STDERR, '>>/dev/null';

main() unless caller;

sub main {
    use POE::Component::Curses;

    use Curses::Toolkit::Widget::Window qw(:all);
    use Curses::Toolkit::Widget::Label qw(:all);
    use Curses::Toolkit::Widget::HBox qw(:all);
    use Curses::Toolkit::Widget::VBox qw(:all);
    use Curses::Toolkit::Widget::Border qw(:all);
    use Curses::Toolkit::Widget::Button qw(:all);
    use Curses::Toolkit::Widget::HProgressBar qw(:all);
    use Curses::Toolkit::Widget::VProgressBar qw(:all);

    my $root = POE::Component::Curses->spawn;

    my $hbar;
    my $vbar;
    {
        my $window1 =
          Window->new->set_name('window')->set_title("manual progress bar")
              ->set_coordinates( x1 => 0, y1 => 0, x2 => '100%', y2 => '100%' );
        $root->add_window($window1);

        $window1->add_widget(
           VBox->new
              ->pack_end(
                  HBox->new
                      ->pack_end(
                          Button->new_with_label('Decrease -')->signal_connect( clicked => 
                              sub {
                                  $hbar->set_position( $hbar->get_position - 1 );
                                  $vbar->set_position( $hbar->get_position - 1 );
                              }),
                          { expand => 0 } )
                      ->pack_end(
                          Button->new_with_label('Increase +')->signal_connect( clicked => 
                              sub {
                                  $hbar->set_position( $hbar->get_position + 1 );
                                  $vbar->set_position( $hbar->get_position + 1 );
                              }),
                          { expand => 0 } )
              )
              ->pack_end(
                  $hbar  = HProgressBar->new,
                  { expand => 0 } )
               ->pack_end(
                 $vbar  = VProgressBar->new,
                 { expand => 0, fill => 1 } )
        );
    }
    POE::Kernel->run();
}
