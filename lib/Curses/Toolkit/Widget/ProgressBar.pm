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

has minimum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw }, traits => [ 'Chained' ] );
has maximum  => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw }, traits => [ 'Chained' ]  );
has position => ( rw, isa => 'Num', lazy_build, trigger => sub { shift->needs_redraw }, traits => [ 'Chained' ]  );
has label_type => ( rw, isa => 'PROGRESS_BAR_LABEL', lazy_build, traits => [ 'Chained' ]  );


# -- builders & initializers

=method new

  input:  none
  output: a Curses::Toolkit::Widget::ProgressBar

=cut

sub _build_minimum    { 0; }
sub _build_maximum    { 100; }
sub _build_position   { 0; }
sub _build_label_type { 'percent'; }

#
# prevent position attribute to be out of bounds
around set_position => sub {
    my ( $orig, $self, $pos ) = @_;
    $pos < $self->get_minimum
        and $pos = $self->get_minimum;
    $pos > $self->get_maximum
        and $pos = $self->get_maximum;
    $self->$orig($pos);
};

=method possible_signals

  my @signals = keys $progressbar->possible_signals();

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

  $progressbar->set_theme_property(property_name => $property_value);
  $value = $progressbar->get_theme_property('property_name');

Here is the list of properties related to the progressbar, that can be
changed in the associated theme. See the L<Curses::Toolkit::Theme> class
used for the default (default class to look at is
L<Curses::Toolkit::Theme::Default>)

Don't forget to look at properties from the parent class, as these are also
inherited from!


=head2 border_width (inherited)

The width of the border of the progressbar.

Example:
  # set the progressbar to have a border of 1
  $progressbar->set_theme_property(border_width => 1 );


=head2 default_length

Sets the value of the default length of the progress bar.

Example :
  # set default_length
  $progressbar->set_theme_property(default_length => 10 );

=head2 char_done

Sets the value of the char used to represent the done portion of the
progress bar.

Example :
  # set char_done
  $progressbar->set_theme_property(char_done => '=' );


=head2 char_left

Sets the value of the char used to represent the left portion of the
progress bar.

Example :
  # set char_left
  $progressbar->set_theme_property(char_left => ' ' );

=head2 start_enclosing

The string to be displayed at the left/top of the progress bar. Usually some enclosing characters.

Example :
  # set left/top enclosing
  $progressbar->set_theme_property(start_enclosing => '< ' );
  $progressbar->set_theme_property(start_enclosing => '[ ' );

=head2 end_enclosing

The string to be displayed at the right/bottom of the progress bar. Usually some enclosing characters.

Example :
  # set right/bottom enclosing
  $progressbar->set_theme_property(end_enclosing => ' >' );
  $progressbar->set_theme_property(end_enclosing => ' ]' );

=cut

sub _get_theme_properties_definition {
    my ($self) = @_;
    return {
        %{ $self->SUPER::_get_theme_properties_definition() },
        start_enclosing => { optional => 0, type => SCALAR, },
        end_enclosing => { optional => 0, type => SCALAR, },
        default_length => { optional => 0, type => SCALAR, },
        char_done => { optional => 0, type => SCALAR, },
        char_left => { optional => 0, type => SCALAR, },
    };
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

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

