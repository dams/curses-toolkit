#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label HBox VBox Entry);

main() unless caller;

sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn();

    my $window;
    my $label;

    $root->add_window( $window = Window->new()->set_name('window')->set_title("title") );

    $window->add_widget(
        VBox->new()
            ->pack_end(
                HBox->new()
                    ->pack_end( Label->new->set_text("Normal Entry"), { expand => 0 } )
                    ->pack_end( Entry->new->set_text("some text"), { expand => 1 } ),
                { expand => 0 }
            )
            ->pack_end(
                HBox->new()
                    ->pack_end( Label->new->set_text("Password Entry"), { expand => 0 } )
                    ->pack_end( Entry->new->set_password_mode(1)
                                ->signal_connect( content_changed => 
                                                  sub {
                                                      my ($event, $entry) = @_;
                                                      $label->set_text( "you've entered: " . $entry->get_text );
                                                  })->set_text("password"),
                                { expand => 1 }
                              ),
                { expand => 0 }
            )
            ->pack_end(
                HBox->new()
                    ->pack_end( $label = Label->new->set_text("you've entered:                    "), { expand => 1 } ),
                { expand => 0 }
            )
    );

	$window->set_coordinates(
		x1 => '10%', y1 => '10%',
		x2 => '90%',
		y2 => '90%',
	);
    print STDERR " AAA\n";
    POE::Kernel->run();
}
