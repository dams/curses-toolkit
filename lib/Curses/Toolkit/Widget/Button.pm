use warnings;
use strict;

package Curses::Toolkit::Widget::Button;

# ABSTRACT: a simple text button widget

use parent qw(Curses::Toolkit::Widget::Border Curses::Toolkit::Role::Focusable);

use Params::Validate qw(:all);
use Curses::Toolkit::Object::Coordinates;


=head1 Appearence

Standard theme :

 < A Button >

With a border

  +----------+
  | A Button |
  +----------+

=head1 DESCRIPTION

The Curses::Toolkit::Widget::Button widget is a classical button widget, used
to attach a function that is called when the button is pressed.

This widget cannot hold any widget. If you want a button with a specific
widget, please use L<Curses::Toolkit::Widget::GenericButton>, however it may
use more space in your interface

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Button

=cut

sub new {
    my $class = shift;

    my $self = $class->SUPER::new();
    $self->{text} = '';
    return $self;
}

=head2 new_with_label

  input : the text of the button
  output : a Curses::Toolkit::Widget::Button

=cut

sub new_with_label {
    my $class = shift;
    my ($text) = validate_pos( @_, { type => SCALAR } );

    my $self = $class->new();
    $self->set_text($text);
    return $self;
}

=head1 METHODS

=head2 set_text

Set the text of the entry

  input  : STRING, the text
  output : the button object

=cut

sub set_text {
    my $self = shift;

    my ($text) = validate_pos( @_, { type => SCALAR } );
    $self->{text} = $text;
    return $self;

}

=head2 get_text

Get the text of the Button

  input  : none
  output : STRING, the Button text

=cut

sub get_text {
    my ($self) = @_;
    return $self->{text};
}

# <----- w1 ---->
#   <-- w2 --->
# < button text >
# --^  o1
# ------- o2 --^

# <----- w1 ---->
#   <-- w2 --->
# < button text >
# <> wl
#              <> wr
# --^  o1
# ------- o2 --^


=head2 draw

=cut

sub draw {
    my ($self) = @_;
    $self->SUPER::draw(); # draw the border if any

    my $theme = $self->get_theme();
    my $c     = $self->get_coordinates();
    my $text  = $self->get_text();

    my $left_string  = $self->get_theme_property('left_enclosing');
    my $right_string = $self->get_theme_property('right_enclosing');
    my $bw           = $self->get_theme_property('border_width');
    my $wl           = length $left_string;
    my $wr           = length $right_string;

    my $w1 = $c->width() - 2 * $bw;
    my $w2 = $w1 - $wl - $wr;
    my $o1 = $wl;
    my $o2 = $w1 - $wr;
    my $t1 = ' ' x ( ( $w2 - length $text ) / 2 );
    my $t2 = ' ' x ( $w2 - length($text) - length($t1) );

    $theme->draw_string( $c->get_x1() + $bw,       $c->get_y1() + $bw, $left_string );
    $theme->draw_string( $c->get_x1() + $bw + $o2, $c->get_y1() + $bw, $right_string );
    $theme->draw_string( $c->get_x1() + $bw + $o1, $c->get_y1() + $bw, $t1 . $text . $t2 );

    return;
}

=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The Button desires the minimum size : text length plus the button brackets

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space { shift->get_minimum_space(@_) }

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space required
The Button requires the text length plus the button brackets

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
    my ( $self, $available_space ) = @_;
    my $text = $self->get_text();

    my $minimum_space = $available_space->clone();
    my $bw            = $self->get_theme_property('border_width');
    my $left_string   = $self->get_theme_property('left_enclosing');
    my $right_string  = $self->get_theme_property('right_enclosing');
    $minimum_space->set(
        x2 => $available_space->get_x1() + 2 * $bw + length($left_string) + length($text) + length($right_string),
        y2 => $available_space->get_y1() + 1 + 2 * $bw,
    );
    return $minimum_space;
}

=head2 possible_signals

my @signals = keys $button->possible_signals();

returns the possible signals that can be used on ths widget. See
L<Curses::Toolkit::Widget::signal_connect> to bind signals to actions

  input  : none
  output : HASH, keys are signal names, values are signal classes

=cut

sub possible_signals {
    my ($self) = @_;
    return (
        $self->SUPER::possible_signals(),
        clicked => 'Curses::Toolkit::Signal::Clicked',
    );
}

=head1 Theme related properties

To set/get a theme properties, you should do :

  $button->set_theme_property(property_name => $property_value);
  $value = $button->get_theme_property('property_name');

Here is the list of properties related to the window, that can be changed in
the associated theme. See the Curses::Toolkit::Theme class used for the default
(default class to look at is Curses::Toolkit::Theme::Default)

Don't forget to look at properties from the parent class, as these are also
inherited from !

=head2 border_width (inherited)

The width of the border of the button.

Example :
  # set buttons to have a border of 1
  $button->set_theme_property(border_width => 1 );

=head2 left_enclosing

The string to be displayed at the left of the button. Usually some enclosing characters.

Example :
  # set left enclosing
  $button->set_theme_property(left_enclosing => '< ' );
  $button->set_theme_property(left_enclosing => '[ ' );

=head2 right_enclosing

The string to be displayed at the right of the button. Usually some enclosing characters.

Example :
  # set left enclosing
  $button->set_theme_property(left_enclosing => ' >' );
  $button->set_theme_property(left_enclosing => ' ]' );

=cut

sub _get_theme_properties_definition {
    my ($self) = @_;
    return {
        %{ $self->SUPER::_get_theme_properties_definition() },
        left_enclosing => {
            optional => 0,
            type     => SCALAR,
        },
        right_enclosing => {
            optional => 0,
            type     => SCALAR,
        },
    };
}

1;
