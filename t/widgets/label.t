#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label);

use Curses::Toolkit;
use Curses::Toolkit::Theme::Default::Test;

my $result;
Curses::Toolkit::Theme::Default::Test->set_writer(
    sub { my ($x, $y, $t) = @_;
          $result .= " $x+$y:$t" }
);

my $root = Curses::Toolkit->init_root_window(
    theme_name => 'Curses::Toolkit::Theme::Default::Test',
    test_environment => { screen_w => 20,
                          screen_h => 10,
                        },
);


my $window =
  Window->new->set_name('window')->set_title("window")
  ->set_coordinates( x1 => 5, y1 => 5, width => 40, height => 5 );
$root->add_window($window);

my $label = Label->new->set_text('Hello World ! hit [ q ] to exit');

$window->add_widget($label);

$root->render;

#use Curses;
#endwin;
#print "PLOP\n";
is($result,
   ' 6+6:               6+7:               6+8:               6+6:H 7+6:e 8+6:l 9+6:l 10+6:o 11+6:  12+6:W 13+6:o 14+6:r 15+6:l 16+6:d 17+6:  18+6:! 19+6:  5+5:--------------- 5+9:--------------- 5+5:| 5+6:| 5+7:| 5+8:| 5+9:| 20+5:| 20+6:| 20+7:| 20+8:| 20+9:| 5+5:+ 5+9:+ 7+5:[ win ]',
   'display label ok',
  );

#done_testing;

