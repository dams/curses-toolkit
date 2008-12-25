package Curses::Toolkit::Theme::Default;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Theme);

use Params::Validate qw(:all);
use Curses;

=head1 NAME

Curses::Toolkit::Theme::Default - default widget theme

=head1 DESCRIPTION

This theme is used by default when rendering widgets.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default

=cut

sub ULCORNER { ACS_ULCORNER; }
sub LLCORNER { ACS_LLCORNER; }
sub URCORNER { ACS_URCORNER; }
sub LRCORNER { ACS_LRCORNER; }
sub HLINE { ACS_HLINE; }
sub VLINE { ACS_VLINE; }

sub draw_hline {
	my ($self, $x1, $y1, $width) = @_;
	$self->_get_curses_handler()->hline($y1, $x1, HLINE(), $width);
	return $self;
}

sub draw_vline {
	my ($self, $x1, $y1, $width) = @_;
	$self->_get_curses_handler()->vline($y1, $x1, VLINE(), $width);
	return $self;
}

sub draw_corner_ul {
	my ($self, $x1, $y1) = @_;
 	$self->_get_curses_handler()->addch($y1, $x1, ULCORNER());
	return $self;
}

sub draw_corner_ll {
	my ($self, $x1, $y1) = @_;
 	$self->_get_curses_handler()->addch($y1, $x1, LLCORNER());
	return $self;
}

sub draw_corner_ur {
	my ($self, $x1, $y1) = @_;
 	$self->_get_curses_handler()->addch($y1, $x1, URCORNER());
	return $self;
}

sub draw_corner_lr {
	my ($self, $x1, $y1) = @_;
 	$self->_get_curses_handler()->addch($y1, $x1, LRCORNER());
	return $self;
}

# sub set_root_background {
# 	curs_bkgd();
# }

# sub draw_border {
# 	my $self = shift;
# 	my %params = validate(@_, { curses_handler => { isa => 'Curses' },
# 								coordinates    => { isa => 'Curses::Toolkit::Object::Coordinates' },
# 								flags          => { isa => 'Curses::Toolkit::Object::Flags' },
# 							  }
#                          );
# 	my $c = $params{coordinates};
# 	my $f = $params{flags};
# 	my $curses = $params{curses_handler};
# 	# draw lines
# 	$curses->hline($c->y1(), $c->x1(), HLINE(), $c->width());
# 	$curses->hline($c->y2(), $c->x1(), HLINE(), $c->width());
# 	$curses->vline($c->y1(), $c->x1(), VLINE(), $c->height());
# 	$curses->vline($c->y1(), $c->x2(), VLINE(), $c->height());
# 	# draw corners
# 	$curses->addch($c->y1(), $c->x1(), ULCORNER());
# 	$curses->addch($c->y1(), $c->x2(), URCORNER());
# 	$curses->addch($c->y2(), $c->x1(), LLCORNER());
# 	$curses->addch($c->y2(), $c->x2(), LRCORNER());

# 	my $pair_nb = 1;
# 	foreach my $bg_nb (0..COLORS()-1) {
# 		foreach my $fg_nb (0..COLORS()-1) {
# #			print STDERR "color pairing : $pair_nb, $fg_nb, $bg_nb \n";
# 			init_pair($pair_nb, $fg_nb, $bg_nb);
# 			$pair_nb++;
# 		}
# 	}

# 	foreach my $x (0..7) {
# 		$curses->addstr(0, ($x+1)*3, $x);
# 	}
# 	foreach my $y (0..7) {
# 		$curses->addstr($y+1, 0, $y);
# 	}

# 	my $pair = 1;
# 	foreach my $x (0..7) {
# 		foreach my $y (0..7) {
# 			COLOR_PAIR($pair);
# 			$curses->attrset(COLOR_PAIR($pair));
# 			$curses->addstr($y+1, ($x+1)*3, "$x$y");
# 			$pair++;
# 		}
# 	}

	
# }


1;
