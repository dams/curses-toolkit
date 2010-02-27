#!/usr/bin/perl

use warnings;
use strict;

use Curses;


my $curses_handler = Curses->new();

has_colors()
	or die "color is not supported";

start_color();

init_pair( 1, COLOR_YELLOW, COLOR_BLUE );

#$curses_handler->attron(COLOR_PAIR(1));
$curses_handler->addstr( 5, 5, '### 1 2 A B Z' );

$curses_handler->attron(A_UNDERLINE);
$curses_handler->addstr( 6, 5, '### 1 2 A B Z' );

$curses_handler->attron(A_BOLD);
$curses_handler->addstr( 7, 5, '### 1 2 A B Z' );

$curses_handler->attron(A_REVERSE);
$curses_handler->addstr( 8, 5, '### 1 2 A B Z' );

$curses_handler->attrset(0);
$curses_handler->addstr( 9,  5, '### 1 2 A B Z' );
$curses_handler->addstr( 10, 5, '### 1 2 A B Z' );


$curses_handler->refresh();
sleep 5;


# A_NORMAL        Normal display (no highlight)
# A_STANDOUT      Best highlighting mode of the terminal
# A_UNDERLINE     Underlining
# A_REVERSE       Reverse video
# A_BLINK         Blinking
# A_DIM           Half bright
# A_BOLD          Extra bright or bold
# A_PROTECT       Protected mode
# A_INVIS         Invisible or blank mode
# A_ALTCHARSET    Alternate character set
# A_CHARTEXT      Bit-mask to extract a character
# COLOR_PAIR(n)   Color-pair number n
