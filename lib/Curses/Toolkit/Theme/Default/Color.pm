package Curses::Toolkit::Theme::Default::Color;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Theme::Default);

use Params::Validate qw(:all);
use Curses;

=head1 NAME

Curses::Toolkit::Theme::Default::Color - default widget theme with color

=head1 DESCRIPTION

This theme is used by default when rendering widgets, if color is available.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default::Color object

=cut


sub new {
	my $class = shift;
	has_colors() or
	  die "Cannot create a '" .  __PACKAGE__ . "' object : color is not supported";
	# pair 1 : yellow on blue
	init_pair(1, COLOR_YELLOW, COLOR_BLUE);
	init_pair(2, COLOR_WHITE, COLOR_RED);
	return $class->SUPER::new(@_);
}

sub HLINE_NORMAL   { shift->_attron(COLOR_PAIR(1)) }
sub HLINE_FOCUSED  { shift->_attron(COLOR_PAIR(2)) }
sub HLINE_CLICKED  { shift->_attron(COLOR_PAIR(1)) }
				   
sub VLINE_NORMAL   { shift->_attron(COLOR_PAIR(1)) }
sub VLINE_FOCUSED  { shift->_attron(COLOR_PAIR(2)) }
sub VLINE_CLICKED  { shift->_attron(COLOR_PAIR(1)) }

sub CORNER_NORMAL  { shift->_attron(COLOR_PAIR(1)) }
sub CORNER_FOCUSED { shift->_attron(COLOR_PAIR(2)) }
sub CORNER_CLICKED { shift->_attron(COLOR_PAIR(1)) }

# STRING as parent


1;
