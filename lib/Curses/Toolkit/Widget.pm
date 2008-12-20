package Curses::Toolkit::Widget;

use warnings;
use strict;

use parent qw(Curses::Toolkit);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget - base class for widgets

=head1 DESCRIPTION

Base class for widgets

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my ($class) = shift;
    # TODO : use Exception;
    $class eq __PACKAGE__ and die "abstract class";
	use Curses::Toolkit::Object::Flags;
	return bless { flags => Curses::Toolkit::Object::Flags->new(),
				   children => [],
				   parent => undef,
				 }, $class;
}

=head1 METHODS

=head2 render

Default rendering method for the widget.

  input  : curses_handler
  output : the widget

=cut

sub render {
	my $self = shift;
    my ($curses_handler) = validate_pos( @_, { isa => 'Curses' } );
	$self->render_border($curses_handler);
	foreach my $child ($self->get_children()) {
		$child->render();
	}
    return;
}

=head2 get_children

Returns the list of children of the widget

  input : none
  output : ARRAY of Curses::Toolkit::Widget

=cut

sub get_children {
	my ($self) = @_;
	return @{$self->{children}};
}

=head2 get_parent

Returns the parent of the widget

  input : none
  output : a Curses::Toolkit::Widget object or undef

=cut

sub get_parent {
	my ($self) = @_;
	return $self->{parent};
}

=head2 render_border

Render the border of the widget

  input  : curses_handler
  output : the widget

=cut

sub render_border {
	my $self = shift;
    my ($curses_handler) = validate_pos( @_, { isa => 'Curses' } );
	$self->get_theme()->draw_border( curses_handler => $curses_handler,
									 coordinates => $self->{coordinates},
									 flags => $self->{flags},
								   );
}

=head2 set_theme

Set a specific display theme.

  input  : a Curses::Toolkit::Theme
  output : the widget

=cut

sub set_theme {
	my $self = shift;
    my ($theme) = validate_pos( @_, { isa => 'Curses::Toolkit::Theme' } );
	$self->{theme} = $theme;
	return $self;
}

=head2 get_theme

Get the widge current theme. If none is set, tries to get it from the parent
widget. If there is no perent widget, sets the theme to a new
Curses::Toolkit::Theme::Default and returns it.

  input  : none
  output : a Curses::Toolkit::Theme object

=cut

sub get_theme {
	my ($self) = @_;
	if ( ! defined $self->{theme} ) {
		my $parent = $self->get_parent();
		defined $parent and
		  return $parent->get_theme();
		use Curses::Toolkit::Theme::Default;
		$self->{theme} = Curses::Toolkit::Theme::Default->new();
	}
	return $self->{theme};
}


=head2 set_border_width

Sets the border width

  input  : the border width
  output : the widget

=cut

sub set_border_width {
	my ($self, $border_width) = @_;
	$self->{border_width} = $border_width;
	return $self;
}

=head2 set_coordinates

Set the coordinates (see L<Curses::Toolkit::Object::Coordinates> )

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
  output : the window

=cut

sub set_coordinates {
	my $self = shift;
	use Curses::Toolkit::Object::Coordinates;
	$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
	return $self;
}

=head2 get_coordinates

Get the coordinates (see L<Curses::Toolkit::Object::Coordinates> )

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object
           or undef;

=cut

sub get_coordinates {
	my ($self) = @_;
	return $self->{coordinates};
}

1;
