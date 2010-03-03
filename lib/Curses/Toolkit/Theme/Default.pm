use warnings;
use strict;

package Curses::Toolkit::Theme::Default;

# ABSTRACT: default widget theme

use parent qw(Curses::Toolkit::Theme);

use Params::Validate qw(:all);
use Curses;

=head1 DESCRIPTION

This theme is used by default when rendering widgets.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default

=cut

# the values of this theme
sub _get_default_properties {
    my ( $self, $class_name ) = @_;
    my %default = (
        'Curses::Toolkit::Widget::Window' => {
            title_width               => 20,
            title_bar_position        => 'top',
            title_position            => 'left',
            title_brackets_characters => [ '[ ', ' ]' ],
            title_left_offset         => 1,
            title_right_offset        => 1,
            title_animation           => 1,
            title_loop_duration       => 4,
            title_loop_pause          => 2 / 3,

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
        'Curses::Toolkit::Widget::Button' => {

            # inherited from Border
            border_width    => 0,
            left_enclosing  => '< ',
            right_enclosing => ' >',
        },

        #  					'Curses::Toolkit::Widget::Paned' => {
        #  					  gutter_size => 1,
        #  					},
        'Curses::Toolkit::Widget::Entry' => {
            default_width   => 3,
            left_enclosing  => '[',
            right_enclosing => ']',
        },
        'Curses::Toolkit::Widget::HProgressBar' => {

            # inherited from Border
            border_width => 0,

            left_enclosing  => '[',
            right_enclosing => ']',
            default_width   => 12,
            char_done       => '|',
            char_left       => '-',
        },
    );
    return $default{$class_name} || {};
}



sub ULCORNER { ACS_ULCORNER; }
sub LLCORNER { ACS_LLCORNER; }
sub URCORNER { ACS_URCORNER; }
sub LRCORNER { ACS_LRCORNER; }
sub HLINE    { ACS_HLINE; }
sub VLINE    { ACS_VLINE; }

sub STRING_NORMAL  { }
sub STRING_FOCUSED { shift->_attron(A_REVERSE) }
sub STRING_CLICKED { shift->_attron(A_BOLD) }

sub TITLE_NORMAL  { }
sub TITLE_FOCUSED { shift->_attron(A_REVERSE) }
sub TITLE_CLICKED { shift->_attron(A_BOLD) }

sub HLINE_NORMAL  { }
sub HLINE_FOCUSED { shift->_attron(A_REVERSE) }
sub HLINE_CLICKED { shift->_attron(A_BOLD) }

sub VLINE_NORMAL  { }
sub VLINE_FOCUSED { shift->_attron(A_REVERSE) }
sub VLINE_CLICKED { shift->_attron(A_BOLD) }

sub CORNER_NORMAL  { }
sub CORNER_FOCUSED { shift->_attron(A_REVERSE) }
sub CORNER_CLICKED { shift->_attron(A_BOLD) }

sub RESIZE_NORMAL  { }
sub RESIZE_FOCUSED { shift->_attron(A_REVERSE) }
sub RESIZE_CLICKED { shift->_attron(A_BOLD) }

sub BLANK_NORMAL  { shift->_set_colors( 'white', 'black' ) }
sub BLANK_FOCUSED { shift->_set_colors( 'white', 'black' ) }
sub BLANK_CLICKED { shift->_set_colors( 'white', 'black' ) }

sub draw_hline {
    my ( $self, $x1, $y1, $width, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $y1 >= 0 or return;
    my $c = $self->restrict_to_shape( x1 => $x1, y1 => $y1, width => $width, height => 1 )
        or return;
    $self->curses($attr)->hline( $c->get_y1(), $c->get_x1(), HLINE(), $c->width() );
    return $self;
}

sub draw_vline {
    my ( $self, $x1, $y1, $height, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $x1 >= 0 or return;
    my $c = $self->restrict_to_shape( x1 => $x1, y1 => $y1, width => 1, height => $height )
        or return;
    $self->curses($attr)->vline( $c->get_y1(), $c->get_x1(), VLINE(), $c->height() );
    return $self;
}

sub draw_corner_ul {
    my ( $self, $x1, $y1, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $self->is_in_shape( x1 => $x1, y1 => $y1, x2 => $x1, y2 => $y1 ) or return;
    $self->curses($attr)->addch( $y1, $x1, ULCORNER() );
    return $self;
}

sub draw_corner_ll {
    my ( $self, $x1, $y1, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $self->is_in_shape( x1 => $x1, y1 => $y1, x2 => $x1, y2 => $y1 ) or return;
    $self->curses($attr)->addch( $y1, $x1, LLCORNER() );
    return $self;
}

sub draw_corner_ur {
    my ( $self, $x1, $y1, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $self->is_in_shape( x1 => $x1, y1 => $y1, x2 => $x1, y2 => $y1 ) or return;
    $self->curses($attr)->addch( $y1, $x1, URCORNER() );
    return $self;
}

sub draw_corner_lr {
    my ( $self, $x1, $y1, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    $self->is_in_shape( x1 => $x1, y1 => $y1, x2 => $x1, y2 => $y1 ) or return;
    $self->curses($attr)->addch( $y1, $x1, LRCORNER() );
    return $self;
}

sub draw_string {
    my ( $self, $x1, $y1, $text, $attr ) = @_;
    $self->get_widget->is_visible() or return;

    use Curses::Toolkit::Object::MarkupString;
    ref $text
        or $text = Curses::Toolkit::Object::MarkupString->new($text);

    my $c = $self->restrict_to_shape( x1 => $x1, y1 => $y1, width => $text->stripped_length(), height => 1 ) or return;

    my $start = $c->get_x1() - $x1;
    my $end   = $c->get_x1() - $x1 + $c->width();
    my $width = $end - $start;
    $text = $text->substring( $start, $width );
    $text->stripped_length() or return;
    $self->_addstr_with_tags( $attr, $c->get_x1(), $c->get_y1(), $text );
    return $self;
}

sub draw_title {
    my ( $self, $x1, $y1, $text, $attr ) = @_;
    $self->get_widget->is_visible() or return;
    my $c = $self->restrict_to_shape( x1 => $x1, y1 => $y1, width => length($text), height => 1 ) or return;

    $c->get_x1() - $x1 < length $text
        or return;
    $text = substr( $text, $c->get_x1() - $x1, $c->width() );
    defined $text && length $text or return;
    $self->curses($attr)->addstr( $c->get_y1(), $c->get_x1(), $text );
    return $self;
}

sub draw_resize {
    my ( $self, $x1, $y1, $attr ) = @_;
    $self->get_widget->is_visible or return;
    $self->is_in_shape( x1 => $x1, y1 => $y1, x2 => $x1, y2 => $y1 ) or return;
    $self->curses($attr)->addch( $y1, $x1, ACS_CKBOARD );
    return $self;
}

sub draw_blank {
    my $self = shift;
    $self->get_widget->is_visible or return;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );
    $c = $self->restrict_to_shape($c)
        or return;
    my $l = $c->get_x2() - $c->get_x1();
    $l > 0 or return $self;
    my $str = ' ' x $l;
    foreach my $y ( $c->get_y1() .. $c->get_y2() - 1 ) {
        $self->curses->addstr( $y, $c->get_x1(), $str );
    }
    return $self;
}

1;
