#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw( $Bin );
use lib "$Bin/../../lib";

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label HBox);

main() unless caller;

sub main {
    use POE::Component::Curses;

    my $root = POE::Component::Curses->spawn();

    my $window;
    $root->add_window( $window = Window->new()->set_name('window')->set_title("title") );

    $window->add_widget(
        my $hbox = HBox->new()
            ->pack_end(
                Label->new->set_text("label1"),
                { expand => 0 }
            )
            ->pack_end(
                Label->new->set_text("label2"),
                { expand => 0 }
            )
    );

	$window->set_coordinates(
		x1 => '10%', y1 => '10%',
		x2 => '90%',
		y2 => '90%',
	);
    POE::Kernel->run();
}
