#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

use Curses::Toolkit::Widget::Label qw(:all);
use Curses::Toolkit::Widget::Window qw(:all);
use Curses::Toolkit::Widget::VBox qw(:all);
use Curses::Toolkit::Widget::HBox qw(:all);
use Curses::Toolkit::Widget::Button qw(:all);

use Curses::Toolkit::Theme::Default;
use Curses::Toolkit::Theme::Default::Color::BlueWhite;
use Curses::Toolkit::Theme::Default::Color::Yellow;
use Curses::Toolkit::Theme::Default::Color::Pink;

my $default = 'Curses::Toolkit::Theme::Default';
my $blue_white = 'Curses::Toolkit::Theme::Default::Color::BlueWhite';
my $yellow = 'Curses::Toolkit::Theme::Default::Color::Yellow';
my $pink = 'Curses::Toolkit::Theme::Default::Color::Pink';


main() unless caller;

sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn( args => { theme_name => $blue_white } );

    my ($button1, $button02, $button03, $button04);

    my $window1 =
      Window->new->set_title("Curses::Toolkit Theme demonstration")
          ->set_coordinates( x1 => '5%', y1 => '30%',
                             x2 => '95%', y2 => '70%' );

    $root->add_window($window1);
    $window1->add_widget(
        VBox->new()->pack_end(
            Label->new->set_justify('center')->set_text("Click these buttons to change the theme"),
            { expand => 1 }
        )->pack_end(
            HBox->new()
                ->pack_end($button1 = Button->new_with_label('Default'),   { expand => 1 } )
                ->pack_end($button02 = Button->new_with_label('BlueWhite'), { expand => 1 } )
                ->pack_end($button03 = Button->new_with_label('Yellow'),    { expand => 1 } )
                ->pack_end($button04 = Button->new_with_label('Pink'),      { expand => 1 } ),
            { expand => 0 }
        )
    );
    $button1->signal_connect( clicked => sub { $window1->set_theme_name($default, 1)} );
    $button02->signal_connect( clicked => sub { $window1->set_theme_name($blue_white, 1)} );
    $button03->signal_connect( clicked => sub { $window1->set_theme_name($yellow, 1)} );
    $button04->signal_connect( clicked => sub { $window1->set_theme_name($pink, 1)} );

    POE::Kernel->run();
}
