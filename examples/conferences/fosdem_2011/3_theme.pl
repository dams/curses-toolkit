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

    my ($button01, $button02, $button03, $button04);

    my $window1 =
      Window->new->set_name('window')->set_title("Theme demonstration")
          ->set_coordinates( x1 => '5%', y1 => '30%',
                             x2 => '95%', y2 => '70%' );

    $root->add_window($window1);
    $window1->add_widget(
        VBox->new()->pack_end(
            Label->new->set_justify('center')->set_text("Click these buttons to change the theme"),
            { expand => 1 }
        )->pack_end(
            HBox->new()
                ->pack_end($button01 = Button->new_with_label('Default'),   { expand => 1 } )
                ->pack_end($button02 = Button->new_with_label('BlueWhite'), { expand => 1 } )
                ->pack_end($button03 = Button->new_with_label('Yellow'),    { expand => 1 } )
                ->pack_end($button04 = Button->new_with_label('Pink'),      { expand => 1 } ),
            { expand => 0 }
        )
    );
    $button01->signal_connect( clicked => sub { $window1->set_theme_name(Default, 1)} );
    $button02->signal_connect( clicked => sub { $window1->set_theme_name(BlueWhite, 1)} );
    $button03->signal_connect( clicked => sub { $window1->set_theme_name(Yellow, 1)} );
    $button04->signal_connect( clicked => sub { $window1->set_theme_name(Pink, 1)} );

    POE::Kernel->run();
}
