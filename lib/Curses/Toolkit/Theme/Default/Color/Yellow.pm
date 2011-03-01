use warnings;
use strict;

package Curses::Toolkit::Theme::Default::Color::Yellow;

# ABSTRACT: default widget theme with color

use parent qw(Curses::Toolkit::Theme::Default::Color);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);
use Curses;

=head1 DESCRIPTION

This theme is used by default when rendering widgets, if color is available.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default::Color object

=cut


sub new {
    my $class = shift;
    has_colors()
        or die "Cannot create a '$class' object : color is not supported";
    return $class->SUPER::new(@_);
}

# the values of this theme
sub _get_default_properties {
    my ( $self, $class_name ) = @_;
    my %properties = (
        'Curses::Toolkit::Widget::Window' => {
            title_width               => 80,
            title_bar_position        => 'top',
            title_position            => 'center',
            title_brackets_characters => [ '< ', ' >' ],
            title_left_offset         => 1,
            title_right_offset        => 1,
            title_animation           => 1,
            title_loop_duration       => 4,
            title_loop_pause          => 2 / 3,

            # inherited from Border
            border_width => 2,
        }    );
    return $properties{$class_name} || $self->SUPER::_get_default_properties($class_name);
}

sub default_fgcolor { 'yellow' }
sub default_bgcolor { 'black' }

sub HLINE_NORMAL  { shift->_set_colors( 'yellow', 'yellow' ) }
sub HLINE_FOCUSED { shift->_set_colors( 'red',    'yellow' )->_attron(A_BOLD) }
sub HLINE_CLICKED { shift->_set_colors( 'yellow', 'yellow' )->_attron(A_REVERSE) }

sub VLINE_NORMAL  { shift->_set_colors( 'yellow', 'yellow' ) }
sub VLINE_FOCUSED { shift->_set_colors( 'red',    'yellow' )->_attron(A_BOLD) }
sub VLINE_CLICKED { shift->_set_colors( 'yellow', 'yellow' )->_attron(A_REVERSE) }

sub CORNER_NORMAL  { shift->_set_colors( 'yellow', 'yellow' ) }
sub CORNER_FOCUSED { shift->_set_colors( 'red',    'yellow' )->_attron(A_BOLD) }
sub CORNER_CLICKED { shift->_set_colors( 'yellow', 'yellow' )->_attron(A_REVERSE) }

sub STRING_NORMAL  { shift->_set_colors( 'white', 'black' ) }
sub STRING_FOCUSED { shift->_set_colors( 'white', 'black' )->_attron(A_REVERSE) }
sub STRING_CLICKED { shift->_set_colors( 'white', 'black' )->_attron(A_BOLD) }

sub VSTRING_NORMAL  { shift->_set_colors( 'white', 'black' ) }
sub VSTRING_FOCUSED { shift->_set_colors( 'white', 'black' )->_attron(A_REVERSE) }
sub VSTRING_CLICKED { shift->_set_colors( 'white', 'black' )->_attron(A_BOLD) }

sub TITLE_NORMAL  { shift->_set_colors( 'black', 'yellow' ) }
sub TITLE_FOCUSED { shift->_set_colors( 'red',   'yellow' )->_attron(A_BOLD) }
sub TITLE_CLICKED { shift->_set_colors( 'black', 'yellow' )->_attron(A_REVERSE) }

sub RESIZE_NORMAL  { shift->_set_colors( 'black', 'yellow' ) }
sub RESIZE_FOCUSED { shift->_set_colors( 'red',    'yellow' )->_attron(A_BOLD) }
sub RESIZE_CLICKED { shift->_set_colors( 'yellow', 'yellow' )->_attron(A_REVERSE) }


1;
