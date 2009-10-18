use warnings;
use strict;

package Curses::Toolkit::Theme::Default::Color::Pink;

use parent qw(Curses::Toolkit::Theme::Default::Color);

use Params::Validate qw(:all);
use Curses;

=head1 NAME

Curses::Toolkit::Theme::Default::Color::Pink - default widget theme with pink-ish color, made for Book

=head1 DESCRIPTION

You want to use this theme if you are a stereotyped girl, or a child, or Book. Or if you like pink. Or.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default::Color::Pink object

=cut


sub new {
	my $class = shift;
	has_colors() or
	  die "Cannot create a '" .  __PACKAGE__ . "' object : color is not supported";
	# pair 1 : yellow on blue
	init_pair(1, COLOR_WHITE, COLOR_MAGENTA);
	init_pair(2, COLOR_BLUE, COLOR_MAGENTA);
	init_pair(3, COLOR_BLACK, COLOR_MAGENTA);
	init_pair(4, COLOR_RED, COLOR_MAGENTA);
#	init_pair(4, COLOR_RED, COLOR_MAGENTA);
#	init_pair(5, COLOR_YELLOW, COLOR_MAGENTA);
#	init_pair(6, COLOR_RED, COLOR_MAGENTA);
	return $class->SUPER::new(@_);
}

sub HLINE_NORMAL   { shift->_attron(COLOR_PAIR(2)) }
sub HLINE_FOCUSED  { shift->_attron(COLOR_PAIR(4) | A_BOLD) }
sub HLINE_CLICKED  { shift->_attron(COLOR_PAIR(2) | A_REVERSE) }
				   
sub VLINE_NORMAL   { shift->_attron(COLOR_PAIR(2)) }
sub VLINE_FOCUSED  { shift->_attron(COLOR_PAIR(4) | A_BOLD) }
sub VLINE_CLICKED  { shift->_attron(COLOR_PAIR(2) | A_REVERSE) }

sub CORNER_NORMAL  { shift->_attron(COLOR_PAIR(2)) }
sub CORNER_FOCUSED { shift->_attron(COLOR_PAIR(4) | A_BOLD) }
sub CORNER_CLICKED { shift->_attron(COLOR_PAIR(2) | A_REVERSE) }

sub STRING_NORMAL  { shift->_attron(COLOR_PAIR(1)) }
sub STRING_FOCUSED { shift->_attron(COLOR_PAIR(2) | A_REVERSE) }
sub STRING_CLICKED { shift->_attron(COLOR_PAIR(2) | A_BOLD) }

sub TITLE_NORMAL  { shift->_attron(COLOR_PAIR(3)) }
sub TITLE_FOCUSED { shift->_attron(COLOR_PAIR(3) | A_BOLD) }
sub TITLE_CLICKED { shift->_attron(COLOR_PAIR(3) | A_REVERSE) }

sub RESIZE_NORMAL  { shift->_attron(COLOR_PAIR(2)) }
sub RESIZE_FOCUSED { shift->_attron(COLOR_PAIR(4) | A_BOLD) }
sub RESIZE_CLICKED { shift->_attron(COLOR_PAIR(2) | A_REVERSE) }

sub BLANK_NORMAL  { shift->_attron(COLOR_PAIR(3)) }
sub BLANK_FOCUSED { shift->_attron(COLOR_PAIR(3)) }
sub BLANK_CLICKED { shift->_attron(COLOR_PAIR(3)) }

1;
