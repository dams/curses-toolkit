package Curses::Toolkit::Theme;

use warnings;
use strict;

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
	return bless { widget => $widget }, $class;
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
	} elsif ( !ref $property_name eq 'HASH' && defined $value) {
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





sub get_widget {
	my ($self) = @_;
	return $self->{widget};
}

sub curses {
	my ($self) = @_;
	$self->_get_curses_handler()->attrset(0);
	my $caller = (caller(1))[3];
	my $type = uc( (split('_', $caller))[1] );
	$self->_compute_attributes($type);
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
	my ($self, $type) = @_;
	my $method = $type . '_NORMAL';
	$self->$method();
# 	if ( ! $self->get_widget()->is_visible() ) {
# 		$method = $type . '_INVISIBLE';
# 	}
	if ( $self->get_widget()->isa('Curses::Toolkit::Role::Focusable') &&
		 $self->get_widget()->is_focused() ) {
		$method = $type . '_FOCUSED';
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
