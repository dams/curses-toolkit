use strict;
use warnings;

package Curses::Toolkit::Widget::VProgressBar;

# ABSTRACT: a vertical progress bar widget

use Moose;
use MooseX::Has::Sugar;
use MooseX::FollowPBP;
use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

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
  output: a Curses::Toolkit::Widget::VProgressBar

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
    my $upper_string  = $self->get_theme_property('start_enclosing');
    my $bottom_string = $self->get_theme_property('end_enclosing');
    my $hu           = length $upper_string;
    my $hb           = length $bottom_string;
    my $bw           = $self->get_theme_property('border_width');


    my $value      = 100 * ( $pos - $min ) / ( $max - $min );
    my $text       = '';
    my $label_type = $self->get_label_type;
    if ( $label_type eq 'percent' ) {
        $text = sprintf( " %.2d%% ", $value );
    } elsif ( $label_type eq 'value' ) {
        $text = "$value";
    }


    # 
    #    ^               _ 
    #    |     ^      ^  # < o1
    #    |     |   hd |  #
    #    |     |      \/ #
    #  h1|   h2|      ^  | < o2
    #    |     |      |  |
    #    |     |   hl |  |
    #    |     |      |  |
    #    |     \/     \/ |
    #    \/              - < o4
    #

    my $h1     = $c->height() - 2 * $bw;
    my $h2     = $h1 - $hu - $hb;
    my $h_done = int( $h2 * ( $pos - $min ) / ( $max - $min ) );
    my $h_left = $h2 - $h_done;

    my $o1 = $hu;
    my $o2 = $o1 + $h_done;
 #   my $o3 = ( $h1 - length $text ) / 2;
    my $o4 = $h1 - $hb;

    $theme->draw_vstring( $c->get_x1() + $bw, $c->get_y1() + $bw, $upper_string );
    $theme->draw_vstring( $c->get_x1() + $bw, $c->get_y1() + $bw + $o4, $bottom_string );

    $theme->draw_vstring( $c->get_x1() + $bw, $c->get_y1() + $bw + $o1, $char_done x $h_done );
    $theme->draw_vstring( $c->get_x1() + $bw, $c->get_y1() + $bw + $o2, $char_left x $h_left );

#    $theme->draw_vstring( $c->get_x1() + $bw, $c->get_y1() + $bw + $o3, $text );

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
    my $default_height = $self->get_theme_property('default_length');
    my $bw            = $self->get_theme_property('border_width');
    my $upper_string  = $self->get_theme_property('start_enclosing');
    my $bottom_string = $self->get_theme_property('end_enclosing');
    $minimum_space->set(
        x2 => $available_space->get_y1() + 1 + 2 * $bw,
        y2 => $available_space->get_x1() + 2 * $bw + length($upper_string) + $default_height + length($bottom_string),
    );
    return $minimum_space;
}


=method possible_signals

  my @signals = keys $vprogressbar->possible_signals();

Returns the possible signals that can be used on this widget. See
L<Curses::Toolkit::Widget::signal_connect> to bind signals to actions

  input:  none
  output: HASH, keys are signal names, values are signal classes

The progress bar accepts no signal.

=cut

=head1 THEME RELATED PROPERTIES

To set/get a theme properties, you should do :

  $vprogressbar->set_theme_property(property_name => $property_value);
  $value = $vprogressbar->get_theme_property('property_name');

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
  $vprogressbar->set_theme_property(border_width => 1 );


=head2 default_length

Sets the value of the default length of the progress bar.

Example :
  # set default_length
  $vprogressbar->set_theme_property(default_length => 10 );

=head2 char_done

Sets the value of the char used to represent the done portion of the
progress bar.

Example :
  # set char_done
  $vprogressbar->set_theme_property(char_done => '=' );


=head2 char_left

Sets the value of the char used to represent the left portion of the
progress bar.

Example :
  # set char_left
  $vprogressbar->set_theme_property(char_left => ' ' );

=head2 start_enclosing

The string to be displayed at the top of the progress bar. Usually some enclosing characters.

Example :
  # set top enclosing
  $vprogressbar->set_theme_property(start_enclosing => '< ' );
  $vprogressbar->set_theme_property(start_enclosing => '[ ' );

=head2 end_enclosing

The string to be displayed at the bottom of the progress bar. Usually some enclosing characters.

Example :
  # set bottom enclosing
  $vprogressbar->set_theme_property(end_enclosing => ' >' );
  $vprogressbar->set_theme_property(end_enclosing => ' ]' );

=cut

no Moose;
__PACKAGE__->meta->make_immutable (inline_constructor => 0);

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

The C<Curses::Toolkit::Widget::VProgressBar> widget is a classical
progress bar widget, used to provide some sort of progress information
to your program user.

This Progress bar is vertical.

