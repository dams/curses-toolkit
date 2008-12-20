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

  input : none
  output : a Curses::Toolkit::Theme::Default

=cut

sub new {
    my ($class) = shift;
	my $self = $class->SUPER::new();
	return $self;
}

sub draw_border {
	my $self = shift;
	my %params = validate(@_, { curses_handler => { isa => 'Curses' },
								coordinates    => { isa => 'Curses::Toolkit::Object::Coordinates' },
								flags          => { isa => 'Curses::Toolkit::Object::Flags' },
							  }
                         );
	my $c = $params{coordinates};
	my $f = $params{flags};
	my $curses = $params{curses_handler};
	$curses->hline($c->y1(), $c->x1(), ACS_HLINE, $c->width());
	$curses->hline($c->y2(), $c->x1(), ACS_HLINE, $c->width());
	$curses->vline($c->y1(), $c->x1(), ACS_VLINE, $c->height());
	$curses->vline($c->y1(), $c->x2(), ACS_VLINE, $c->height());

}
1;
