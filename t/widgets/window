#!perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use TestWrapper qw(:all);

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window);

my ($screen_width, $screen_height) = (60, 15);
my $root = create_root_window($screen_width, $screen_height);

# first, a fullscreen window
$root->add_window(
  my $window = Window->new()->set_name('main_window')->set_coordinates(
      x1 => 0,
      y1 => 0,
      x2 => 60,
      y2 => 15
));

my @expected = (
'+----------------------------------------------------------+',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'|                                                          |',
'+----------------------------------------------------------#');

is(grab_frame($root), join("\n", @expected), 'window properly drawn');

$window->set_title("foobar");

substr($expected[0], 2, 10, '[ foobar ]' );

is(grab_frame($root), join("\n", @expected), 'window has a title');
