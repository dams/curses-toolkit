use strict;
use warnings;

package Curses::Toolkit::Widget::ProgressBar;

# ABSTRACT: a simple progress bar widget

use Moose;
use MooseX::Has::Sugar;
use MooseX::FollowPBP;
use Params::Validate qw(:all);

use Curses::Toolkit::Object::Coordinates;
use Curses::Toolkit::Types;

extends qw(Curses::Toolkit::Widget::Border);


# -- attributes

=attr minimum

The minimum value (a float) for the progress bar. Default to 0.

=attr maximum

The maximum value (a float) for the progress bar. Default to 100.

=attr position

The current value of the progress bar. Default to 0.

=attr label

What to show in the progress bar. Must be a C<PROGRESS_BAR_LABEL> -
check L<Curses::Toolkit::Types> for valid options. Default to
C<percent>.

=cut

has minimum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has maximum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has position => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has label => ( rw, isa => 'PROGRESS_BAR_LABEL', lazy_build );


# -- builders & initializers

=method new

  input:  none
  output: a Curses::Toolkit::Widget::ProgressBar

=cut

sub _build_minimum  {0}
sub _build_maximum  {100}
sub _build_position {0}
sub _build_label    {'percent'}


=method draw

Redraw the progress bar.

=cut

sub draw {
	my ($self) = @_;
	$self->SUPER::draw(); # draw the border if any

	my $theme = $self->get_theme();
	my $c     = $self->get_coordinates();
	my $w     = $c->width();

	# [|||||||||||----34%--------------]
	#  <- $done -><-       $left     ->

	my $cdone = $self->get_theme_property('char_done');
	my $cleft = $self->get_theme_property('char_left');
	my $bw    = $self->get_theme_property('border_width');

	my $min = $self->get_minimum;
	my $max = $self->get_maximum;
	my $pos = $self->get_position;
	$pos = $self->get_minimum if $pos < $self->get_minimum;
	$pos = $self->get_maximum if $pos > $self->get_maximum;

	my $done = ( $pos - $min ) / ( $max - $min ) * $w;
	my $left = ( $max - $pos - $min ) / ( $max - $min ) * $w;

	$theme->draw_string( $c->x1() + $bw,         $c->y1() + $bw, $cdone x $done );
	$theme->draw_string( $c->x1() + $bw + $done, $c->y1() + $bw, $cleft x $left );

	#$theme->draw_string($c->x1() + $bw + $o1, $c->y1() + $bw, $t1 . $text . $t2);

	return;
}

=method get_desired_space

Given a coordinate representing the available space, returns the space desired
The Button desires the minimum size : text length plus the button brackets

  input:  a Curses::Toolkit::Object::Coordinates object
  output: a Curses::Toolkit::Object::Coordinates object

The desired space is as much horizontal space as possible, with a height of 1.

=cut

sub get_desired_space {
	my ( $self, $available_space ) = @_;
	my $desired = $available_space->clone;
	$desired->set( y2 => $desired->y1 + 1 );
	return $desired;
}

=method get_minimum_space

Given a coordinate representing the available space, returns the
minimum space required The Button requires the text length plus the
button brackets.

  input:  a Curses::Toolkit::Object::Coordinates object
  output: a Curses::Toolkit::Object::Coordinates object

The ProgressBar requires 12x1 minimum.

=cut

sub get_minimum_space {
	my ( $self, $available_space ) = @_;

	my $minimum_space = $available_space->clone;
	my $default_width = $self->get_theme_property('default_width');
	$minimum_space->set(
		x2 => $available_space->x1() + $default_width,
		y2 => $available_space->y1() + 1,
	);
	return $minimum_space;
}


=method possible_signals

  my @signals = keys $button->possible_signals();

Returns the possible signals that can be used on this widget. See
L<Curses::Toolkit::Widget::signal_connect> to bind signals to actions

  input:  none
  output: HASH, keys are signal names, values are signal classes

The progress bar accepts no signal.

=cut

sub possible_signals {
	my ($self) = @_;
	return $self->SUPER::possible_signals();
}


=head1 THEME RELATED PROPERTIES

To set/get a theme properties, you should do :

  $button->set_theme_property(property_name => $property_value);
  $value = $button->get_theme_property('property_name');

Here is the list of properties related to the window, that can be
changed in the associated theme. See the L<Curses::Toolkit::Theme> class
used for the default (default class to look at is
L<Curses::Toolkit::Theme::Default>)

Don't forget to look at properties from the parent class, as these are also
inherited from!


=head2 border_width (inherited)

The width of the border of the button.

Example:
  # set buttons to have a border of 1
  $button->set_theme_property(border_width => 1 );


=head2 default_width

Sets the value of the default width of the progress bar.


=head2 char_done

Sets the value of the char used to represent the done portion of the
progress bar.

Example :
  # set char_done
  $entry->set_theme_property(char_done => '=' );


=head2 char_left

Sets the value of the char used to represent the left portion of the
progress bar.

Example :
  # set char_left
  $entry->set_theme_property(char_left => '=' );

=cut

sub _get_theme_properties_definition {
	my ($self) = @_;
	return {
		%{ $self->SUPER::_get_theme_properties_definition() },
		default_width => { optional => 0, type => SCALAR, },
		char_done     => { optional => 0, type => SCALAR, },
		char_left     => { optional => 0, type => SCALAR, },
	};
}

1;
__END__


=head1 Appearence

Standard theme:

  ||||||||---------- 14% ------------------

With a border:

  +------------------------------------------+
  |||||||||---------- 14% -------------------|
  +------------------------------------------+


=head1 DESCRIPTION

The C<Curses::Toolkit::Widget::ProgressBar> widget is a classical
progress bar widget, used to provide some sort of progress information
to your program user.


