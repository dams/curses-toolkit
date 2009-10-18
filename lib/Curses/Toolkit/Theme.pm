use warnings;
use strict;

package Curses::Toolkit::Theme;

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Theme - base class for widgets themes

=head1 DESCRIPTION

Base class for widgets themes

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my $class = shift;
	my ($widget) = validate_pos(@_, { isa => 'Curses::Toolkit::Widget' });
    $class eq __PACKAGE__ and die "abstract class";
	my $self =  bless { widget => $widget }, $class;
	$self->set_property(ref $widget, $self->_get_default_properties(ref $widget));
	return $self;
}

=head2 set_property

  $theme->set_property('Toolkit::Curses::Widget::Class', 'property name', 'value');
  $widget->set_property('Toolkit::Curses::Widget::Class', { name1 => 'value1', ... });

Sets a single property or a whole group of property

Properties are arbitrary caracteristics of widgets. For themes, they are
grouped by Widgets class name. The property will be set for all widgets from
this class using the theme. To set a property, you need to specify the class
name of the widget you want to theme , then the property name, then the value
name. However you can specify the class name, and a hash representing multiple names / values

Returns the widget.

=cut

sub set_property {
	my $self = shift;
	my $class_name = shift;
	my $definition = $class_name->_get_theme_properties_definition();
	my ($property_name, $value) = @_;
	my $parameters = {};
	if (ref $property_name eq 'HASH' && !defined $value) {
		$parameters = $property_name;
	} elsif ( !ref $property_name) {
		$parameters = { $property_name => $value };
	}

	my @parameters = %$parameters;
	my %params = validate(@parameters, $definition);

	@{$self->{property}{$class_name}}{keys %params} = values %params;
	return $self;
}

=head2 get_property

  my $value = $widget->get_property('Toolkit::Curses::Widget::Class', 'property name');
  my $hash = $widget->get_property('Toolkit::Curses::Widget::Class');

Return the theme property or the hash of properties of a widget.

=cut

sub get_property {
	my $self = shift;
	my ($class_name, $property_name) = validate_pos( @_, 1, 0 );
	my $properties = $self->{property}{$class_name};
	defined $properties or $properties = {};
	if (defined $property_name) {
		return $properties->{$property_name};
	}
	return( { %$properties } );
}

=head2 get_widget

  my $widget = $theme_instance->get_widget();

Returns the widget of this theme instance, or undef

=cut

sub get_widget {
	my ($self) = @_;
	defined $self->{widget} or return;
	return $self->{widget};
}

=head2 get_window

  my $widget = $theme_instance->get_window();

Returns the window of this theme instance, or void

=cut

sub get_window {
	my ($self) = @_;
	my $widget = $self->get_widget()
	  or return;
	my $window = $widget->get_window()
	  or return;
	return $window;
}

=head2 get_root_window

  my $widget = $theme_instance->get_root_window();

Returns the root window of this theme instance, or void

=cut

sub get_root_window {
	my ($self) = @_;
	my $window = $self->get_window()
	  or return;
	my $root_window = $window->get_root_window()
	  or return;
	return $root_window;
}

=head2 get_shape

  my $widget = $theme_instance->get_shape();

Returns the shape of the root window of this theme instance, or void

=cut

sub get_shape {
	my ($self) = @_;
	my $root_window = $self->get_root_window()
	  or return;
	my $shape = $root_window->get_shape()
	  or return;
	return $shape;
}

=head2 is_in_shape

  my $coordinates = $theme_instance->is_in_shape( $coordinate );
  my $coordinates = $theme_instance->is_in_shape( x1 => 1, y1 => 1, x2 => 25, y2 => 10 );
  my $coordinates = $theme_instance->is_in_shape( x1 => 1, y1 => 1, width => 4, height => 1 );

Returns true / false if the given coordinates are in the current shape. Or
returns void if there is no root window.

=cut

sub is_in_shape {
	my $self = shift;
	my $shape = $self->get_shape()
	  or return;
	return Curses::Toolkit::Object::Coordinates->new( @_ )
	  ->is_inside($shape);
}

=head2 restrict_to_shape

  my $coordinates = $theme_instance->restrict_to_shape( $coordinate );
  my $coordinates = $theme_instance->restrict_to_shape( x1 => 1, y1 => 1, x2 => 25, y2 => 10 );
  my $coordinates = $theme_instance->restrict_to_shape( x1 => 1, y1 => 1, width => 4, height => 1 );

Given a coordinates, returns it restricted to the shape of the root window, or
void if there is no root window. Useful to draw text / line and make sure thay
are in the shape

=cut

sub restrict_to_shape {
	my $self = shift;
	my $shape = $self->get_shape()
	  or return;
	return Curses::Toolkit::Object::Coordinates->new( @_ )
	  ->restrict_to($shape);
}

=head2 curses

  my $curses_object = $theme_instance->curses($attr);

Returns the Curses object. $attr is an optional HASHREF that
can contain these keys:

  bold : set bold on / off
  reverse : set reverse on / off
  focused : draw in focused mode
  clicked : draw in clicked mode

=cut

sub curses {
	my ($self, $attr) = @_;
	$self->_get_curses_handler()->attrset(0);
	my $caller = (caller(1))[3];
	my $type = uc( (split('_', $caller))[1] );
	$self->_compute_attributes($type, $attr);
	if (defined $attr) {
		use Curses;
		if (exists $attr->{bold}) {
			$attr->{bold} and $self->_attron(A_BOLD);
			$attr->{bold} or  $self->_attroff(A_BOLD);
		}
		if (exists $attr->{reverse}) {
			$attr->{reverse} and $self->_attron(A_REVERSE);
			$attr->{reverse} or  $self->_attroff(A_REVERSE);
		}
	}
	return $self->_get_curses_handler();
}

# gets the curses handler of the associated widget
#
#  input  : none
#  output : a Curses object
sub _get_curses_handler {
	my ($self) = @_;
	return $self->get_widget()->_get_curses_handler();
}

sub _compute_attributes {
	my ($self, $type, $attr) = @_;
	$attr ||= { };
	my $method = $type . '_NORMAL';
	$self->$method();
# 	if ( ! $self->get_widget()->is_visible() ) {
# 		$method = $type . '_INVISIBLE';
# 	}
	if ( ( $self->get_widget()->isa('Curses::Toolkit::Role::Focusable') &&
		   $self->get_widget()->is_focused() )
		 || delete $attr->{focused}
	   ) {
		$method = $type . '_FOCUSED';
		$self->$method();
	}
	if (delete $attr->{clicked}) {
		$method = $type . '_CLICKED';
		$self->$method();
	}
	return;
}

sub _attron {
	my $self = shift;
	$self->_get_curses_handler()->attron(@_);
}

sub _attroff {
	my $self = shift;
	$self->_get_curses_handler()->attroff(@_);
}

sub _attrset {
	my $self = shift;
	$self->_get_curses_handler()->attrset(@_);
}

1;
