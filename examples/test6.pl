#!/usr/bin/perl

use Curses;

  initscr();
  start_color();

  cbreak();
  raw();
  noecho();
  nonl();

  # Both of these achieve nonblocking input.
  nodelay(1);
  timeout(0);

  keypad(1);
  intrflush(0);
  meta(1);
  typeahead(-1);

  my $old_mouse_events = 0;
  mousemask(REPORT_MOUSE_POSITION, $old_mouse_events); # ALL_MOUSE_EVENTS

  clear();
  refresh();


print STDERR " start\n";

while (my $keystroke = Curses::getch) {
	$keystroke eq '-1' and next;
	print STDERR " key : $keystroke\n";
	$keystroke eq 'q' and last
}

endwin;

