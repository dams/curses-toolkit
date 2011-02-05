#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

open STDERR, '>>/dev/null';


use Net::Twitter;
my $nt = Net::Twitter->new();


use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label VBox HBox Button HPaned Entry);

use relative -to      => "Curses::Toolkit::Theme::Default::Color",
             -aliased => qw(BlueWhite Yellow Pink);

use relative -to      => "Curses::Toolkit::Theme",
             -aliased => qw(Default);

main() unless caller;

sub search_twitter {
    my ($button, $entry) = @_;
    print STDERR "\n -------- button widget : $button\n";
    print STDERR "\n -------- entry widget : $entry\n";
}


sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn( args => { theme_name => BlueWhite } );

    my ($button01, $button02, $button03, $button04);


    my $entry;
    my $window1 =
      Window->new->set_name('window')->set_title("Theme demonstration")
          ->set_coordinates( x1 => '5%', y1 => '5%',
                             x2 => '95%', y2 => '95%' );

    $root->add_window($window1);
    $window1->add_widget(
        VBox->new
            ->pack_end(
                HPaned->new
                      ->set_name('hpaned')
                      ->set_gutter_position(30)
                      ->add1(
                          VBox->new
                              ->pack_end(
                                  HBox->new
                                      ->pack_end(
                                          $entry = Entry->new(),
                                          { expand => 1 }
                                      )
                                      ->pack_end(
                                          Button->new_with_label('Search')
                                                ->signal_connect( clicked => \&search_twitter, $entry ),
                                          { expand => 0 }
                                      ),
                                  { expand => 0 }
                              )
                      )
                      ->add2(
                          VBox->new()
                              ->pack_end(
                                  Label->new
                                       ->set_justify('center')
                                       ->set_text("Please try to search for something..."),
                                  { expand => 0 }
                                        )
                      ),
                      { expand => 1 }
            )
            ->pack_end(
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





#my $results = $nt->public_timeline();


#    my $results = $nt->search('perl');

# print Dumper($results); use Data::Dumper;


