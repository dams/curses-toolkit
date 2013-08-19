#!perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use TestWrapper qw(:all);

use relative -to      => "Curses::Toolkit::Widget",
             -aliased => qw(Window Label);

my ($screen_width, $screen_height) = (20, 5);
my $root = create_root_window($screen_width, $screen_height);

# first, a fullscreen window
$root->add_window(
  my $window = Window->new()->set_name('main_window')->set_coordinates(
      x1 => 0,
      y1 => 0,
      width => 20,
      height => 5,
));

$window->set_theme_property(border_width => 0);
$window->add_widget(Label->new()->set_text('foo bar'));
my @expected = (
'foo bar             ',
'                    ',
'                    ',
'                    ',
'                    ',
);

is(grab_frame($root), join("\n", @expected), 'window properly drawn');

