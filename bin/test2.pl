#! /usr/bin/perl
##
##  demo -- do some curses stuff
##
##  Copyright (c) 1994-2000  William Setzer
##
##  You may distribute under the terms of either the Artistic License
##  or the GNU General Public License, as specified in the README file.

use Curses;

my           $win = new Curses();
           addstr(10, 10, 'foo');
           $win->refresh;

# my $c = Curses->new();

# start_color();
# $c->hline(3, 2, ACS_HLINE, 20);
# $c->refresh();
# initscr();
# $b = subwin(10, 20, 3, 3);

# noecho();
# cbreak();

# addstr(0, 0, "ref b = " . ref $b);
# addstr(1, 1, "fooalpha");

# eval { attron(A_BOLD) };
# addstr(2, 5, "bold  ");
# eval { attron(A_REVERSE) };
# addstr("bold+reverse");
# eval { attrset(A_NORMAL) };
# addstr("  normal  (if your curses supports these modes)");

# addstr(6, 1, "do12345678901234567890n't worry be happy");
# eval { box($b, '|', '-') };

# standout($b);
# addstr($b, 2, 2, "ping");
# standend($b);
# addstr($b, 4, 4, "pong");

# move($b, 3, 3);
# move(6, 3);
# deleteln($b);
# insertln();

# delch($b, 4, 5);
# insch(7, 8, ord(a));

# eval { keypad(1) };
# addstr(14, 0, "hit a key: ");
# refresh();
# $ch = getch();

# addstr(15, 0, "you typed: >>");
# addch($ch);
# addstr("<< and perl thinks you typed: >>$ch<<");

# addstr(17, 0, "enter string: ");
# refresh();
# getstr($str);

# addstr(18, 0, "you typed: >>$str<<");
# getyx($m, $n);
# addstr(19, 4, "y == $m (should be 18), x == $n (should be "
#          . (15 + length $str) . ")");

# $ch = inch(19, 7);
# addstr(20, 0, "The character at (19,7) is an '$ch' (should be an '=')");

# addstr(21, 0, "testing KEY_*.  Hit the up arrow on your keyboard: ");
# refresh();
# $ch = getch();
# eval
# { 
#     if ($ch == KEY_UP) { addstr(22, 0, "KEY_UP was pressed!") }
#     else               { addstr(22, 0, "Something else was pressed.") }
#     1;
# } || addstr(22, 0, "You don't seem to have the KEY_UP macro");

# move($LINES - 1, 0);
 refresh();
 sleep 2;
 endwin();
