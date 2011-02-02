#!/usr/bin/env perl

use strict;
use warnings;
#use diagnostics;

use FindBin;

use Curses::UI;




my $cui = new Curses::UI(-color_support => 1,
			 -clear_on_exit => 0);

my $co = $Curses::UI::color_object;

my @colors = $co->get_colors();
my @labels;

my $mainw = $cui->add('screen', 'Window');

for my $i (0..$ENV{LINES} - 1) {
my $label =$mainw->add("label$i",'Label', -fg => $colors[int rand @colors], 
	                     -bg => $colors[int rand @colors], 
                             -text => " " x $i . "Curses::UI::Color",
		             -paddingspaces => 1,
		             -width => -1,
		             -y => $i);

push @labels, $label;
}
$cui->draw();

while (1) {
    my $nr = int rand @labels;
    $labels[$nr]->set_color_fg($colors[int rand @colors]);
    $labels[$nr]->set_color_bg($colors[int rand @colors]);
    $cui->draw();
}

