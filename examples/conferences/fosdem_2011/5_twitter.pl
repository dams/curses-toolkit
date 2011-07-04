#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../../lib";

#open STDERR, '>>/dev/null';


use Net::Twitter;
my $nt = Net::Twitter->new();


use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label VBox HBox Button HPaned Entry Border);

use relative -to      => "Curses::Toolkit::Theme::Default::Color",
             -aliased => qw(BlueWhite Yellow Pink);

use relative -to      => "Curses::Toolkit::Theme",
             -aliased => qw(Default);

main() unless caller;

my $border;

sub search_twitter {
    my ($event, $button, $entry) = @_;

    my $query = $entry->get_text;

    defined $query && length $query
      or return;

    $border->remove_widget();
    $border->add_widget(
        VBox->new->pack_end(
            Label->new
                 ->set_justify('center')
                 ->set_text("searching for $query..."),
            { expand => 0 }
        )
    );
    $border->needs_redraw();

    my $struct = $nt->search($query);
    my $results = $struct->{results};
    $border->remove_widget();
    my $vbox = VBox->new;
    foreach my $result (@$results) {
        my $from_user = $result->{from_user};
        my $to_user = $result->{to_user};
        my $message = $result->{text};
        $message =~ s|$query|<span fgcolor='red'>$query</span>|;
        my $text = "<u><b>" . $from_user . "</b></u> said : $message";
        $vbox->pack_end(
            Label->new
                 ->set_justify('left')
                 ->set_text($text),
            { expand => 0 }
        );
    }
    $border->add_widget($vbox);
    $border->needs_redraw();

}


sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn( args => { theme_name => BlueWhite } );

    my ($button01, $button02, $button03, $button04);


    my $entry;

    my $window1 =
      Window->new->set_name('window')->set_title("Twitter Search demonstration at FOSDEM")
          ->set_coordinates( x1 => '5%', y1 => '5%',
                             x2 => '95%', y2 => '95%' );

    $root->add_window($window1);
    $window1->add_widget(
        VBox->new->pack_end(
            HPaned->new
              ->set_name('hpaned')
              ->set_gutter_position(30)
              ->add1(
                  VBox->new->pack_end(
                      HBox->new->pack_end(
                          $entry = Entry->new(),
                          { expand => 1 }
                      )->pack_end(
                          Button->new_with_label('Search')
                            ->signal_connect( clicked => \&search_twitter, $entry ),
                          { expand => 0 }
                      ),
                      { expand => 0 }
                  )
              )
              ->add2(
                  $border = Border->new()->add_widget(
                      VBox->new()->pack_end(
                          Label->new
                            ->set_justify('center')
                            ->set_text("Please try to search for something..."),
                          { expand => 0 }
                      )
                  )
              ),
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


