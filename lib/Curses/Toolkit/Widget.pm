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
				   parent => undef,
				   name => 'unknown',
 				   relatives_coordinates => Curses::Toolkit::Object::Coordinates
 				                            ->new_zero(),
				   properties => {},
				 }, $class;
}

=head1 METHODS

=head2 set_name

Set the name of the widget. It's only a help, the name is used only in error
message, so that you know which sicget it is talking about. Default name is
'unknown'.

  input  : the name
  output : the widget

=cut

sub set_name {
	my ($self, $name) = @_;
	$self->{name} = $name;
	return $self;
}

=head2 get_name

Get the name of a widget

  input  : the widget
  output : the name

=cut

sub get_name {
	my ($self) = @_;
	return $self->{name};
}

=head2 set_property

  $widget->set_property('group name', 'property name', 'value');
  $widget->set_property('group name', { name1 => 'value1', ... });

Sets a single property or a whole group of property

properties are arbitrary caracteristics of widgets. They are grouped by
groups. To set a property, you need to specify the group name, then the
property name, then the value name. However you can specify the group name, and
a hash representing this group value.

Returns the widget

=cut

sub set_property {
	my ($self, $group_name, $property_name, $value) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' }, 1, 1, 0 );
	if (defined $value) {
		$self->{property}{$group_name}{$property_name} = $value;
		return $self;
	}
	my $group_value = $property_name;
	$self->{property}{$group_name} = $group_value;
	return $self;
}

=head2 get_property

  my $value = $widget->get_property('group name', 'property name');
  my $group_hash = $widget->get_property('group name');

Return the property or the group of property of a widget.

=cut

sub get_property {
	my ($self, $group_name, $property_name) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' }, { optional => 0 }, { optional => 1} );
	my $group = $self->{property}{$group_name};
	if (defined $property_name) {
		return $group->{$property_name};
	}
	return( { %$group } );
}

=head2 draw

This is the method that draws the widget itself.
Default drawing for the widget.
This method doesn't draw anything

=cut

sub draw { return; }

=head2 render

Default rendering method for the widget. Any rendre method should call draw

  input  : curses_handler
  output : the widget

=cut

sub render {
	my ($self) = @_;
	$self->draw();
    return;
}

# Sets the parent of the widget
#
#  input : Curses::Toolkit::Widget::Container object
#  output : the current widget

sub _set_parent {
	my $self = shift;
	my ($widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget::Container' } );
	$self->{parent} = $widget;
	return $self;
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

# =head2 render_border

# Render the border of the widget

#   input  : curses_handler
#   output : the widget

# =cut

# sub render_border {
# 	my $self = shift;
#     my ($curses_handler) = validate_pos( @_, { isa => 'Curses' } );
# 	$self->get_theme()->draw_border( curses_handler => $curses_handler,
# 									 coordinates => $self->{coordinates},
# 									 flags => $self->{flags},
# 								   );
# 	return;
# }

=head2 set_theme_name

Set a specific display theme name.

  input  : a STRING, name of a class inheriting from Curses::Toolkit::Theme
  output : the widget

=cut

sub set_theme_name {
	my $self = shift;
    my ($theme_name) = validate_pos( @_, { type => SCALAR }
									 # isa => 'Curses::Toolkit::Theme' }
								   );
	$self->{theme_name} = $theme_name;
	return $self;
}

=head2 get_theme_class

Get the theme name used for this widget. If there is none, tries to get it from
the parent. If there is no parent, the default theme name is used

  input  : none
  output : a STRING, name of a class inheriting from Curses::Toolkit::Theme

=cut

sub get_theme_name {
	my ($self) = @_;
	if ( ! defined $self->{theme_name} ) {
		my $parent = $self->get_parent();
		defined $parent and
		  return $parent->get_theme_name();
		$self->{theme_name} = 'Curses::Toolkit::Theme::Default';
	}
	return $self->{theme_name};
}

=head2 get_theme

Get the widget current theme instance. If none is set, creates a new instance
from the widget's theme name (see L<get_theme_name>).

  input  : none
  output : a Curses::Toolkit::Theme object

=cut

sub get_theme {
	my ($self) = @_;
	if ( ! defined $self->{theme} ) {
		$self->{theme} = $self->get_theme_name()->new($self);
	}
	return $self->{theme};
}


# =head2 set_border_width

# Sets the border width

#   input  : the border width
#   output : the widget

# =cut

# sub set_border_width {
# 	my ($self, $border_width) = @_;
# 	$self->{border_width} = $border_width;
# 	return $self;
# }

=head2 get_coordinates

Get the absolute coordinates (see L<Curses::Toolkit::Object::Coordinates> )

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_coordinates {
	my ($self) = @_;
	defined $self->{coordinates} and
	  return $self->{coordinates};
	my $parent = $self->get_parent();
	if (defined $parent) {
		my $pc = $parent->get_coordinates();
		my $rc = $self->get_relatives_coordinates();
		use Curses::Toolkit::Object::Coordinates;
		my $c = Curses::Toolkit::Object::Coordinates->new(
			x1 => $pc->x1() + $rc->x1(), y1 => $pc->y1() + $rc->y1(),
			x2 => $pc->x1() + $rc->x2(), y2 => $pc->y1() + $rc->y2(),
		);
		return $c;
	}
	die "widget of name '" . $self->get_name() . "' (type '" . ref($self) . "') has no coordinates.";
}

=head2 get_relatives_coordinates

Get the relative coordinates (see L<Curses::Toolkit::Object::Coordinates> )

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_relatives_coordinates {
	my ($self) = @_;
	defined $self->{relatives_coordinates} or
	  die "widget of name '" . $self->get_name() . "' (type '" . ref($self) . "') has no relatives coordinate\n";
	return $self->{relatives_coordinates};
}

=head2 rebuild_coordinates

  $widget->rebuild_coordinates();

Recompute all the relative coordinates accross the whole window

  input  : none
  output : the root window

=cut

sub rebuild_all_coordinates {
	my ($self) = @_;
	my $widget = $self;
	while ( ! $widget->isa('Curses::Toolkit::Widget::Window') ) {
		$widget = $widget->get_parent();
		# if when going through all parent we don't find a window, just
		# return : we can't rebuild the coordinates
		defined $widget or return $self;
	}
	my $window = $widget;
	$window->_rebuild_children_coordinates();
	return $self;	
}

# sets the relatives coordinates, from the origin of the parent widget
#  input  : any Curses::Toolkit::Object::Coordinates costructor input
#  output : the widget
sub _set_relatives_coordinates {
	my $self = shift;
	use Curses::Toolkit::Object::Coordinates;
	$self->{relatives_coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
	return $self;
}

# Sets the Curses object to the widget.
#
#  input  : a Curses object
#  output : the current widget

sub _set_curses_handler {
	my $self = shift;
    my ($curses_handler) = validate_pos( @_, { isa => 'Curses' } );
	$self->{curses_handler} = $curses_handler;
	return $self;
}

# Returns the Curses object. Typically called when drawing things
#
#  input  : none
#  output : a Curses object

sub _get_curses_handler {
	my ($self) = @_;
	defined $self->{curses_handler} and
	  return $self->{curses_handler};
	my $parent = $self->get_parent();
	defined $parent and
	  return $parent->_get_curses_handler();
	die "couldn't get Curses object from widget (name '" . $self->get_name() . "' type '" . ref($self) ."')";
}

1;
