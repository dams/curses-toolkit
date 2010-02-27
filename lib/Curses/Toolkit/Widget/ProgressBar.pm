use strict;
use warnings;

package Curses::Toolkit::Widget::ProgressBar;

# ABSTRACT: progress bar widget base class

use Moose;
use MooseX::Has::Sugar;
use MooseX::FollowPBP;
use Params::Validate qw(:all);

use Curses::Toolkit::Object::Coordinates;
use Curses::Toolkit::Types;

extends qw(Curses::Toolkit::Widget::Border);

# FIXME this is an abstract class. How do you specify this in moose ?

# -- attributes

=attr minimum

The minimum value (a float) for the progress bar. Default to 0.

=attr maximum

The maximum value (a float) for the progress bar. Default to 100.

=attr position

The current value of the progress bar. Default to 0.

=attr label_type

What to show in the progress bar. Must be a C<PROGRESS_BAR_LABEL> -
check L<Curses::Toolkit::Types> for valid options. Default to
C<percent>.

=cut

has minimum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has maximum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has position => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw } );
has label_type => ( rw, isa => 'PROGRESS_BAR_LABEL', lazy_build );


# -- builders & initializers

=method new

  input:  none
  output: a Curses::Toolkit::Widget::ProgressBar

=cut

sub _build_minimum  { 0; }
sub _build_maximum  { 100; }
sub _build_position { 0; }
sub _build_label_type    { 'percent'; }

#
# prevent position attribute to be out of bounds
around set_position => sub {
	my ($orig, $self, $pos) = @_;
	$pos < $self->get_minimum
	  and $pos = $self->get_minimum;
	$pos > $self->get_maximum
	  and $pos = $self->get_maximum;
	$self->$orig($pos);
};

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
		char_done     => { optional => 0, type => SCALAR, },
		char_left     => { optional => 0, type => SCALAR, },
	};
}

1;

__END__

=head1 SYNOPSIS

    # don't use this widget directly

=head1 DESCRIPTION

A ProgressBar widget is a widget that displays a progress bar horizontally or
vertically

Don't use this widget directly. Please see
L<Curses::Toolkit::Widget::HProgressBar> and
L<Curses::Toolkit::Widget::VProgressBar>.

