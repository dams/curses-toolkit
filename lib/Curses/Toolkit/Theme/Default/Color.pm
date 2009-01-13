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
	return $class->SUPER::new(@_);
}

# pair 1 : yellow on blue

#  	my $pair_nb = 1;
#  	foreach my $bg_nb (0..COLORS()-1) {
#  		foreach my $fg_nb (0..COLORS()-1) {
#  #			print STDERR "color pairing : $pair_nb, $fg_nb, $bg_nb \n";
#  			init_pair($pair_nb, $fg_nb, $bg_nb);
#  			$pair_nb++;
#  		}
#  	}

#init_pair(1, 2, 4);#COLOR_YELLOW, COLOR_BLUE);

#sub HLINE { ACS_HLINE; }

sub draw_hline {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_hline(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_vline {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_vline(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_corner_ul {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_corner_ul(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_corner_ll {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_corner_ll(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_corner_ur {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_corner_ur(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_corner_lr {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_corner_lr(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}

sub draw_strinf {
	my $self = shift;
	$self->_get_curses_handler()->attrset(COLOR_PAIR(1));
	my @ret = $self->SUPER::draw_text(@_);
	$self->_get_curses_handler()->attroff(COLOR_PAIR(1));
	return @ret;
}


1;
