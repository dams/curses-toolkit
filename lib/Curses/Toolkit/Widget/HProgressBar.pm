use strict;
use warnings;

package Curses::Toolkit::Widget::HProgressBar;

# ABSTRACT: a horizontal progress bar widget

use Moose;
use MooseX::Has::Sugar;
use MooseX::FollowPBP;
use Params::Validate qw(:all);

use Curses::Toolkit::Object::Coordinates;
use Curses::Toolkit::Types;

extends qw(Curses::Toolkit::Widget::ProgressBar);


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

=method new

  input:  none
  output: a Curses::Toolkit::Widget::HProgressBar

=cut

=method draw

Redraw the progress bar.

=cut

sub draw {
    my ($self) = @_;
    $self->SUPER::draw(); # draw the border if any

    my $theme = $self->get_theme();
    my $c     = $self->get_coordinates();
    my $min   = $self->get_minimum;
    my $max   = $self->get_maximum;
    my $pos   = $self->get_position;

    my $char_done    = $self->get_theme_property('char_done');
    my $char_left    = $self->get_theme_property('char_left');
    my $left_string  = $self->get_theme_property('left_enclosing');
    my $right_string = $self->get_theme_property('right_enclosing');
    my $wl           = length $left_string;
    my $wr           = length $right_string;
    my $bw           = $self->get_theme_property('border_width');


    my $value      = 100 * ( $pos - $min ) / ( $max - $min );
    my $text       = '';
    my $label_type = $self->get_label_type;
    if ( $label_type eq 'percent' ) {
        $text = sprintf( " %.2d%% ", $value );
    } elsif ( $label_type eq 'value' ) {
        $text = "$value";
    }

    # <------------ w1 ---------------->
    #  <------------ w2 -------------->
    #  <-$w_done-><-     $w_left     ->
    # [|||||||||||----34%--------------]
    # -^  o1
    # ----- o2 ---^
    # --------- o3 ---^
    # ---------------- o4 -------------^

    my $w1     = $c->width() - 2 * $bw;
    my $w2     = $w1 - $wl - $wr;
    my $w_done = int( $w2 * ( $pos - $min ) / ( $max - $min ) );
    my $w_left = $w2 - $w_done;

    my $o1 = $wl;
    my $o2 = $o1 + $w_done;
    my $o3 = ( $w1 - length $text ) / 2;
    my $o4 = $w1 - $wr;

    $theme->draw_string( $c->get_x1() + $bw,       $c->get_y1() + $bw, $left_string );
    $theme->draw_string( $c->get_x1() + $bw + $o4, $c->get_y1() + $bw, $right_string );

    $theme->draw_string( $c->get_x1() + $bw + $o1, $c->get_y1() + $bw, $char_done x $w_done );
    $theme->draw_string( $c->get_x1() + $bw + $o2, $c->get_y1() + $bw, $char_left x $w_left );

    $theme->draw_string( $c->get_x1() + $bw + $o3, $c->get_y1() + $bw, $text );

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
    my $desired_space = $available_space->clone;
    $desired_space->set( y2 => $desired_space->get_y1 + 1 );
    $desired_space->grow_to($self->get_minimum_space($available_space));
    return $desired_space;
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
    my $bw            = $self->get_theme_property('border_width');
    my $left_string   = $self->get_theme_property('left_enclosing');
    my $right_string  = $self->get_theme_property('right_enclosing');
    $minimum_space->set(
        x2 => $available_space->get_x1() + 2 * $bw + length($left_string) + $default_width + length($right_string),
        y2 => $available_space->get_y1() + 1 + 2 * $bw,
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

=head1 THEME RELATED PROPERTIES

To set/get a theme properties, you should do :

  $hprogress_bar->set_theme_property(property_name => $property_value);
  $value = $button->get_theme_property('property_name');

Here is the list of properties related to the progressbar, that can be
changed in the associated theme. See the L<Curses::Toolkit::Theme> class
used for the default (default class to look at is
L<Curses::Toolkit::Theme::Default>)

Don't forget to look at properties from the parent class, as these are also
inherited from!


=head2 border_width (inherited)

The width of the border of the progress bar.

Example:
  # set buttons to have a border of 1
  $hprogressbar->set_theme_property(border_width => 1 );


=head2 default_width

Sets the value of the default width of the progress bar.

=head2 char_done

Sets the value of the char used to represent the done portion of the
progress bar.

Example :
  # set char_done
  $hprogressbar->set_theme_property(char_done => '=' );


=head2 char_left

Sets the value of the char used to represent the left portion of the
progress bar.

Example :
  # set char_left
  $hprogressbar->set_theme_property(char_left => '=' );

=head2 left_enclosing

The string to be displayed at the left of the progress bar. Usually some enclosing characters.

Example :
  # set left enclosing
  $hprogressbar->set_theme_property(left_enclosing => '< ' );
  $hprogressbar->set_theme_property(left_enclosing => '[ ' );

=head2 right_enclosing

The string to be displayed at the right of the progress bar. Usually some enclosing characters.

Example :
  # set left enclosing
  $hprogressbar->set_theme_property(left_enclosing => ' >' );
  $hprogressbar->set_theme_property(left_enclosing => ' ]' );

=cut

sub _get_theme_properties_definition {
    my ($self) = @_;
    return {
        %{ $self->SUPER::_get_theme_properties_definition() },
        default_width   => { optional => 0, type => SCALAR, },
        left_enclosing  => { optional => 0, type => SCALAR, },
        right_enclosing => { optional => 0, type => SCALAR, },

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


