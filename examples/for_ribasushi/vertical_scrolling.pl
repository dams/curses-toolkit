#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";

use POE::Component::Curses;
use Curses::Toolkit::Widget::Window;
use Curses::Toolkit::Widget::Button;
use Curses::Toolkit::Widget::VBox;
use Curses::Toolkit::Widget::HProgressBar;
use Curses::Toolkit::Widget::Border;


my $c = 0;
my @themes = qw(Curses::Toolkit::Theme::Default
Curses::Toolkit::Theme::Default::Color::BlueWhite
Curses::Toolkit::Theme::Default::Color::Pink
Curses::Toolkit::Theme::Default::Color::Yellow);

my @bars = map { 
    Curses::Toolkit::Widget::HProgressBar->new
      ->set_position(int(rand() * 100));
} (1..10);

# spawn a root window
my $root = POE::Component::Curses->spawn();
  # adds some widget
$root->add_window(
    my $window = Curses::Toolkit::Widget::Window
        ->new()
        ->set_name('main_window')
        ->add_widget(
            my $vbox = Curses::Toolkit::Widget::VBox->new
        )
        ->set_coordinates(x1 => 0,   y1 => 0,
                          x2 => '100%',
                          y2 => '100%',
                         )
);

$window->set_theme_property(border_width => 0);


foreach my $bar (@bars) {
    my $bordered_bar = Curses::Toolkit::Widget::Border->new->add_widget($bar);
    $bordered_bar->set_theme_name($themes[$c++]);    
    $c == 4 and $c = 0;

    $vbox->pack_end( $bordered_bar, { expand => 0 } );

    $bar->set_label_type('none');
    $bar->set_theme_property({ char_done => '=',
                               char_left => ' ',
                             }
                            );
}

$root->add_delay(0.5, \&update_bars, $root, \@bars);

# start main loop
POE::Kernel->run();

sub update_bars {
    my ($root, $bars) = @_;
    foreach my $bar (@bars) {
        $bar->set_position($bar->get_position + (rand() > 0.5 ? 1 : -1 ));
    }    
    $root->add_delay(0.5, \&update_bars, $root, \@bars);
}
