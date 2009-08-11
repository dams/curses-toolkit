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

# the values of this theme
sub _get_default_properties {
	my ($self, $class_name) = @_;
	my %default = ( 'Curses::Toolkit::Widget::Window' => {
			          title_width => 20,
					  title_bar_position => 'top',
					  title_position => 'left',
					  title_brackets_characters => [ '[ ', ' ]' ],
					  title_left_offset => 1,
					  title_right_offset => 1,
					  title_animation => 1,
					  title_loop_duration => 4,
					  title_loop_pause => 2/3,
					  # inherited from Border
					  border_width => 1,
					},
					'Curses::Toolkit::Widget::Border' => {
					  border_width => 1,
					},
					'Curses::Toolkit::Widget::GenericButton' => {
					  # inherited from Border
					  border_width => 1,
					},
#  					'Curses::Toolkit::Widget::Paned' => {
#  					  gutter_size => 1,
#  					},
# 					'Curses::Toolkit::Widget::Entry' => {
# 					  default_width => 20,
# 					},
				  );
	return $default{$class_name} || {};
}



sub ULCORNER { ACS_ULCORNER; }
sub LLCORNER { ACS_LLCORNER; }
sub URCORNER { ACS_URCORNER; }
sub LRCORNER { ACS_LRCORNER; }
sub HLINE { ACS_HLINE; }
sub VLINE { ACS_VLINE; }

sub STRING_NORMAL  { }
sub STRING_FOCUSED { shift->_attron(A_REVERSE) }
sub STRING_CLICKED { shift->_attron(A_BOLD) }

sub TITLE_NORMAL  { }
sub TITLE_FOCUSED { shift->_attron(A_REVERSE) }
sub TITLE_CLICKED { shift->_attron(A_BOLD) }

sub HLINE_NORMAL   { }
sub HLINE_FOCUSED  { shift->_attron(A_REVERSE) }
sub HLINE_CLICKED  { shift->_attron(A_BOLD) }
				   
sub VLINE_NORMAL   { }
sub VLINE_FOCUSED  { shift->_attron(A_REVERSE) }
sub VLINE_CLICKED  { shift->_attron(A_BOLD) }

sub CORNER_NORMAL  { }
sub CORNER_FOCUSED { shift->_attron(A_REVERSE) }
sub CORNER_CLICKED { shift->_attron(A_BOLD) }

sub RESIZE_NORMAL  { }
sub RESIZE_FOCUSED { shift->_attron(A_REVERSE) }
sub RESIZE_CLICKED { shift->_attron(A_BOLD) }

sub BLANK_NORMAL  { shift->_attrset() }
sub BLANK_FOCUSED { shift->_attrset() }
sub BLANK_CLICKED { shift->_attrset() }

sub draw_hline {
	my ($self, $x1, $y1, $width, $attr) = @_;
	$self->get_widget->is_visible() or return;
	my $name = $self->get_widget()->get_name();

	$self->curses($attr)->hline($y1, $x1, HLINE(), $width);

	return $self;
}

sub draw_vline {
	my ($self, $x1, $y1, $width, $attr) = @_;
	$self->get_widget->is_visible() or return;
	my $name = $self->get_widget()->get_name();
	$self->curses($attr)->vline($y1, $x1, VLINE(), $width);
	return $self;
}

sub draw_corner_ul {
	my ($self, $x1, $y1, $attr) = @_;
	$self->get_widget->is_visible() or return;
 	$self->curses($attr)->addch($y1, $x1, ULCORNER());
	return $self;
}

sub draw_corner_ll {
	my ($self, $x1, $y1, $attr) = @_;
	$self->get_widget->is_visible() or return;
 	$self->curses($attr)->addch($y1, $x1, LLCORNER());
	return $self;
}

sub draw_corner_ur {
	my ($self, $x1, $y1, $attr) = @_;
	$self->get_widget->is_visible() or return;
 	$self->curses($attr)->addch($y1, $x1, URCORNER());
	return $self;
}

sub draw_corner_lr {
	my ($self, $x1, $y1, $attr) = @_;
	$self->get_widget->is_visible() or return;
 	$self->curses($attr)->addch($y1, $x1, LRCORNER());
	return $self;
}

sub draw_string {
	my ($self, $x1, $y1, $text, $attr) = @_;
	$self->get_widget->is_visible() or return;
	$self->curses($attr)->addstr($y1, $x1, $text);
	return $self;
}

sub draw_title {
	my ($self, $x1, $y1, $text, $attr) = @_;
	$self->get_widget->is_visible() or return;
	$self->curses($attr)->addstr($y1, $x1, $text);
	return $self;
}

sub draw_resize {
	my ($self, $x1, $y1, $attr) = @_;
	$self->get_widget->is_visible or return;
	$self->curses($attr)->addch($y1, $x1, ACS_CKBOARD);
	return $self;
}

sub draw_blank {
	my $self = shift;
	$self->get_widget->is_visible or return;
	my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );
	my $l = $c->x2() - $c->x1();
	$l > 0 or return $self;
	my $str = ' ' x $l;
	foreach my $y ($c->y1()..$c->y2()-1) {
		$self->curses->addstr($y, $c->x1(), $str);
	}
	return $self;
}

1;
