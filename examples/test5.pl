#!/usr/bin/perl

use Curses;
my $curses = Curses->new();

has_colors() or
  die "no color";

start_color();
#init_pair(1, COLOR_YELLOW, COLOR_BLACK);
#$curses->attron(COLOR_PAIR(1));
#$curses->addstr(4, 4, "TEST");

my %colors = (
			  black => COLOR_BLACK,
			  red => COLOR_RED,
			  green => COLOR_GREEN,
			  yellow => COLOR_YELLOW,
			  blue => COLOR_BLUE,
			  magenta => COLOR_MAGENTA,
			  cyan => COLOR_CYAN,
			  white => COLOR_WHITE,
			 );

my $counter = 1;
foreach my $fg (keys %colors) {
#	foreach my $bg (keys %colors) {
		init_pair($counter, $colors{$fg}, COLOR_MAGENTA);
		$curses->attron(COLOR_PAIR($counter));
		$curses->addstr($y, 0, "fg = $fg | bg = $bg");
		$counter++;
		$y++;
#	}
}

$curses->refresh();
sleep;
