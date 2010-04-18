#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";
main() unless caller;

sub main {
    use POE::Component::Curses;

    use Curses::Toolkit::Widget::Window;
    use Curses::Toolkit::Widget::Label;
    use Curses::Toolkit::Widget::HBox;
    use Curses::Toolkit::Widget::VBox;
    use Curses::Toolkit::Widget::Border;
    use Curses::Toolkit::Widget::Button;
    use Curses::Toolkit::Widget::HProgressBar;
    use Curses::Toolkit::Widget::VProgressBar;

    my $root = POE::Component::Curses->spawn;

    my $hbar;
    my $vbar;
    {
        my $window1 =
          Curses::Toolkit::Widget::Window->new->set_name('window')->set_title("manual progress bar")
              ->set_coordinates( x1 => 0, y1 => 0, x2 => '100%', y2 => 30 );
        $root->add_window($window1);

        $window1->add_widget(
          Curses::Toolkit::Widget::VBox->new
          ->pack_end(
            Curses::Toolkit::Widget::HBox->new
            ->pack_end(
              Curses::Toolkit::Widget::Border->new
              ->add_widget(
                Curses::Toolkit::Widget::VBox->new
                ->pack_end(
                  Curses::Toolkit::Widget::Label->new->set_text('Click to decrease'),
                  { expand => 0 },
                )
                ->pack_end(
                  Curses::Toolkit::Widget::Button->new_with_label('-')->signal_connect( clicked => 
                      sub {
                          $hbar->set_position( $hbar->get_position - 1 );
                          $vbar->set_position( $hbar->get_position - 1 );
                      }),
                  { expand => 0 },
                )
              ),
              { expand => 0 },
            )
            ->pack_end(
              Curses::Toolkit::Widget::VBox->new
              ->pack_end(
                $hbar  = Curses::Toolkit::Widget::HProgressBar->new,
                { expand => 1 },
              )
               ->pack_end(
                 $vbar  = Curses::Toolkit::Widget::VProgressBar->new,
                 { expand => 1 },
               ),
              { expand => 1 },
            )
            ->pack_end(
              Curses::Toolkit::Widget::Border->new
              ->add_widget(
                Curses::Toolkit::Widget::VBox->new
                ->pack_end(
                  Curses::Toolkit::Widget::Label->new->set_text('Click to increase'),
                  { expand => 0 },
                )
                ->pack_end(
                  Curses::Toolkit::Widget::Button->new_with_label('+')->signal_connect( clicked =>
                      sub {
                          $hbar->set_position( $hbar->get_position + 1 );
                          $vbar->set_position( $hbar->get_position + 1 );
                      }),
                  { expand => 0 },
                )
              ),
              { expand => 0 },
            ),
            { expand => 1 },
          )
          ->pack_end(
			Curses::Toolkit::Widget::Button->new_with_label('Exit')->signal_connect( clicked => sub {exit} ),
			{ expand => 0 }
          )
        );
    }
    POE::Kernel->run();
}
