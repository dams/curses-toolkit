use warnings;
use strict;

package Curses::Toolkit::Theme::Default::Color::Pink;

# ABSTRACT: default widget theme with pink-ish color, made for Book

use parent qw(Curses::Toolkit::Theme::Default::Color);

use Params::Validate qw(:all);
use Curses;


=head1 DESCRIPTION

You want to use this theme if you are a stereotyped girl, or a child, or Book. Or if you like pink. Or.

=head1 CONSTRUCTOR

=head2 new

  input : a Curses::Toolkit::Widget
  output : a Curses::Toolkit::Theme::Default::Color::Pink object

=cut


sub new {
	my $class = shift;
	has_colors()
		or die "Cannot create a '" . __PACKAGE__ . "' object : color is not supported";
	return $class->SUPER::new(@_);
}

sub default_fgcolor {'white'}
sub default_bgcolor {'magenta'}


# the values of this theme
sub _get_default_properties {
	my ( $self, $class_name ) = @_;
	my %properties = (
		'Curses::Toolkit::Widget::Button' => {

			# inherited from Border
			border_width    => 1,
			left_enclosing  => '',
			right_enclosing => '',
		},
	);
	return $properties{$class_name} || $self->SUPER::_get_default_properties($class_name);
}

sub HLINE_NORMAL  { shift->_set_colors( 'blue', 'magenta' ) }
sub HLINE_FOCUSED { shift->_set_colors( 'red',  'magenta' )->_attron(A_BOLD) }
sub HLINE_CLICKED { shift->_set_colors( 'blue', 'magenta' )->_attron(A_REVERSE) }

sub VLINE_NORMAL  { shift->_set_colors( 'blue', 'magenta' ) }
sub VLINE_FOCUSED { shift->_set_colors( 'red',  'magenta' )->_attron(A_BOLD) }
sub VLINE_CLICKED { shift->_set_colors( 'blue', 'magenta' )->_attron(A_REVERSE) }

sub CORNER_NORMAL  { shift->_set_colors( 'blue', 'magenta' ) }
sub CORNER_FOCUSED { shift->_set_colors( 'red',  'magenta' )->_attron(A_BOLD) }
sub CORNER_CLICKED { shift->_set_colors( 'blue', 'magenta' )->_attron(A_REVERSE) }

sub STRING_NORMAL  { shift->_set_colors( 'white', 'magenta' ) }
sub STRING_FOCUSED { shift->_set_colors( 'blue',  'magenta' )->_attron(A_REVERSE) }
sub STRING_CLICKED { shift->_set_colors( 'blue',  'magenta' )->_attron(A_BOLD) }

sub TITLE_NORMAL  { shift->_set_colors( 'black', 'magenta' ) }
sub TITLE_FOCUSED { shift->_set_colors( 'black', 'magenta' )->_attron(A_BOLD) }
sub TITLE_CLICKED { shift->_set_colors( 'blue',  'magenta' )->_attron(A_REVERSE) }

sub RESIZE_NORMAL  { shift->_set_colors( 'blue', 'magenta' ) }
sub RESIZE_FOCUSED { shift->_set_colors( 'red',  'magenta' )->_attron(A_BOLD) }
sub RESIZE_CLICKED { shift->_set_colors( 'blue', 'magenta' )->_attron(A_REVERSE) }

sub BLANK_NORMAL  { shift->_set_colors( 'black', 'magenta' ) }
sub BLANK_FOCUSED { shift->_set_colors( 'black', 'magenta' ) }
sub BLANK_CLICKED { shift->_set_colors( 'black', 'magenta' ) }

1;
