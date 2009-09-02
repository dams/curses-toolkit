#!/usr/bin/perl -w
use strict;

use FindBin;
use lib "$FindBin::RealBin/../lib";
use Curses::UI;

my $cui = new Curses::UI (-clear_on_exit => 1,
			  -mouse_support => 1);

my $sw = $cui->add(
    undef, 'Window',
    -y => -1,
    -height => 3,
    -width => -1,
    -border => 1,
);
my $status = $sw->add(
    undef, 'Label',
    -width => -1,
    -padright => 8,
    -text => 'Status: program started... Use the mouse to shift focus'
);
$sw->add(
    undef, 'Buttonbox',
    -buttons => [{
        -label=>'< Quit >',
	-onpress => sub {exit(0)},
    }],
    -width => 8,
    -buttonalignment => 'right',
    -x => -1,
);


for my $nr (1..5)
{
    $cui->add(
	undef, 'Window',
	-x => 12*$nr - 9,
	-y => 2*$nr - 1,
	-width => 20, 
	-height => 10,
	-border => 1,
	-title => "window $nr",
	-onfocus => sub{
	    $status->text("Status: Focus to window $nr"); 
	},
    );
}

$cui->set_binding(sub{exit}, "\cC", "\cQ");

if ($Curses::UI::ncurses_mouse) {
    $status->text($status->text() . " (mouse support enabled)"); 
} else {
    $status->text($status->text() . " (mouse support disabled)"); 
}

$cui->mainloop;
