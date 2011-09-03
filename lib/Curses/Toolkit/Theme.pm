use warnings;
use strict;

package Curses::Toolkit::Theme;

# ABSTRACT: base class for widgets themes

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);
use Curses;

=head1 DESCRIPTION

Base class for widgets themes

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

# service color initialization;
my $color_initialized = 0;

sub new {
    my $class = shift;
    my ($widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' } );
    $class eq __PACKAGE__ and die "abstract class";
    my $self = bless { widget => $widget }, $class;
    $self->set_property( ref $widget, $self->_get_default_properties( ref $widget ) );
    $color_initialized or $class->_init_themes_colors();
    return $self;
}

sub default_fgcolor { 'white' }
sub default_bgcolor { 'black' }

my %colors_to_pair;

sub _init_themes_colors {
    my ($class) = @_;
    if ( has_colors() ) {

        # default color 0, can't be changed.
        $colors_to_pair{'white'}{'black'} = 0;

        # define all posisble color
        my $counter                 = 1;
        my %colors_to_curses_colors = (
            black   => COLOR_BLACK,
            red     => COLOR_RED,
            green   => COLOR_GREEN,
            yellow  => COLOR_YELLOW,
            blue    => COLOR_BLUE,
            magenta => COLOR_MAGENTA,
            cyan    => COLOR_CYAN,
            white   => COLOR_WHITE,
        );
        my @color = keys %colors_to_curses_colors;
        foreach my $fgcolor (@color) {
            foreach my $bgcolor (@color) {
                $fgcolor eq 'white' && $bgcolor eq 'black'
                    and next;
                init_pair( $counter, $colors_to_curses_colors{$fgcolor}, $colors_to_curses_colors{$bgcolor} );
                $colors_to_pair{$fgcolor}{$bgcolor} = COLOR_PAIR($counter);
                $counter++;
            }
        }
        $color_initialized = 1;
    }
}

sub _set_fgcolor {
    my ( $self, $fgcolor ) = @_;
    $self->{_fgcolor} = $fgcolor;
    return $self;
}

sub _set_bgcolor {
    my ( $self, $bgcolor ) = @_;
    $self->{_bgcolor} = $bgcolor;
    my ( $package, $filename, $line ) = caller;
    return $self;
}

sub _set_colors {
    my ( $self, $fgcolor, $bgcolor ) = @_;
    $self->_set_bgcolor($bgcolor);
    $self->_set_fgcolor($fgcolor);
    return $self;
}

sub _get_fg_color { shift->{_fgcolor}; }

sub _get_bg_color { shift->{_bgcolor}; }

sub _get_color_pair {
    my ($self) = @_;
    has_colors()
        or die "Color is not supported by your terminal";
    return $colors_to_pair{ $self->_get_fg_color() }{ $self->_get_bg_color() };
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
    my $self       = shift;
    my $class_name = shift;
    my $definition = $class_name->_get_theme_properties_definition();
    my ( $property_name, $value ) = @_;
    my $parameters = {};
    if ( ref $property_name eq 'HASH' && !defined $value ) {
        $parameters = $property_name;
    } elsif ( !ref $property_name ) {
        $parameters = { $property_name => $value };
    }

    my @parameters = %$parameters;
    my %params = validate( @parameters, $definition );

    @{ $self->{property}{$class_name} }{ keys %params } = values %params;
    return $self;
}

=head2 get_property

  my $value = $widget->get_property('Toolkit::Curses::Widget::Class', 'property name');
  my $hash = $widget->get_property('Toolkit::Curses::Widget::Class');

Return the theme property or the hash of properties of a widget.

=cut

sub get_property {
    my $self = shift;
    my ( $class_name, $property_name ) = validate_pos( @_, 1, 0 );
    my $properties = $self->{property}{$class_name};
    defined $properties or $properties = {};
    if ( defined $property_name ) {
        return $properties->{$property_name};
    }
    return ( {%$properties} );
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
    my $shape = $self->get_widget->get_visible_shape();

    #	my $root_window = $self->get_root_window()
    #	  or return;
    #	my $shape = $root_window->get_shape()
    #	  or return;

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
    my $self  = shift;
    my $shape = $self->get_shape()
        or return;
    return Curses::Toolkit::Object::Coordinates->new(@_)->is_inside($shape);
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
    my $self  = shift;
    my %args = @_;
    my $attr = delete $args{attr} || {};
    my $c = Curses::Toolkit::Object::Coordinates->new(%args);
    $attr->{no_shape_restriction}
      and return $c;
    my $shape = $self->get_shape()
        or return;
    return $c->restrict_to($shape);
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
    my ( $self, $attr ) = @_;
    my $caller = ( caller(1) )[3];
    my $type = uc( ( split( '_', $caller ) )[1] );
    $self->_compute_attributes( $type, $attr );
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
    my ( $self, $type, $attr ) = @_;

    # reset display attributes
    $self->_get_curses_handler()->attrset(0);
    $attr ||= {};
    $self->_set_fgcolor( $self->default_fgcolor() );
    $self->_set_bgcolor( $self->default_bgcolor() );

    # get the type of attributes we want, and call the method
    my $method = $type . '_NORMAL';
    $self->$method();
    if ( ( $self->get_widget()->isa('Curses::Toolkit::Role::Focusable') && $self->get_widget()->is_focused() )
        || delete $attr->{focused} )
    {
        $method = $type . '_FOCUSED';
        $self->$method();
    }
    if ( delete $attr->{clicked} ) {
        $method = $type . '_CLICKED';
        $self->$method();
    }

    # check if additional attributes need to be applied
    if ( exists $attr->{bold} ) {
        $attr->{bold} and $self->_attron(A_BOLD);
        $attr->{bold} or $self->_attroff(A_BOLD);
    }
    if ( exists $attr->{reverse} ) {
        $attr->{reverse} and $self->_attron(A_REVERSE);
        $attr->{reverse} or $self->_attroff(A_REVERSE);
    }
    if ( exists $attr->{fgcolor} ) {
        $self->_set_fgcolor( $attr->{fgcolor} );
    }
    if ( exists $attr->{bgcolor} ) {
        $self->_set_bgcolor( $attr->{bgcolor} );
    }
    has_colors()
        and $self->_get_curses_handler()->attron( $self->_get_color_pair() );
    return;
}

sub _attron {
    my $self = shift;
    $self->_get_curses_handler()->attron(@_);
    return $self;
}

sub _attroff {
    my $self = shift;
    $self->_get_curses_handler()->attroff(@_);
}

sub _attrset {
    my $self = shift;
    $self->_get_curses_handler()->attrset(@_);
}

sub _addstr_with_tags {
    my ( $self, $initial_attr, $x, $y, $text ) = @_;

    use Curses::Toolkit::Object::MarkupString;
    ref $text
        or $text = Curses::Toolkit::Object::MarkupString->new($text);

    my $struct = $text->get_attr_struct();

    # get the curses handler
    my $curses = $self->_get_curses_handler();

    my $caller = ( caller(1) )[3];
    my $type = uc( ( split( '_', $caller ) )[1] );

    foreach my $element (@$struct) {
        my ( $char, @attrs ) = @$element;
        $self->_compute_attributes( $type, $initial_attr );
        my $value = 0;


        my %weight_to_const = (
            normal    => A_NORMAL,
            standout  => A_STANDOUT,
            underline => A_UNDERLINE,
            reverse   => A_REVERSE,
            blink     => A_BLINK,
            dim       => A_DIM,
            bold      => A_BOLD
        );

        foreach my $attr (@attrs) {
            my $weight = $attr->{weight};
            if ( defined $weight && $weight ) {
                my $v = $weight_to_const{$weight};
                if ( defined $v ) {
                    $value = ( $value | $v );
                } else {
                    warn
                        "WARNING : you used this string as value for the 'weight' attribute in one of the <span> tags in your strings : '$weight'. However it's not supported. Available 'weight' values are : "
                        . join( ', ', keys %weight_to_const );
                }
                $weight eq 'normal'
                    and $value = 0;
            }

            defined $attr->{fgcolor}
                and $self->_set_fgcolor( $attr->{fgcolor} );
            defined $attr->{bgcolor}
                and $self->_set_bgcolor( $attr->{bgcolor} );
        }
        has_colors()
            and $value = ( $value | $self->_get_color_pair() );
        $curses->attron($value);
        $curses->addstr( $y, $x, $char );
        $x++;
    }
    return $self;
}

1;

__END__

=begin Pod::Coverage

BLANK_CLICKED
BLANK_FOCUSED
BLANK_NORMAL
CORNER_CLICKED
CORNER_FOCUSED
CORNER_NORMAL
HLINE
HLINE_CLICKED
HLINE_FOCUSED
HLINE_NORMAL
LLCORNER
LRCORNER
RESIZE_CLICKED
RESIZE_FOCUSED
RESIZE_NORMAL
STRING_CLICKED
STRING_FOCUSED
STRING_NORMAL
VSTRING_CLICKED
VSTRING_FOCUSED
VSTRING_NORMAL
ULCORNER
URCORNER
TITLE_CLICKED
TITLE_FOCUSED
TITLE_NORMAL
VLINE
VLINE_CLICKED
VLINE_FOCUSED
VLINE_NORMAL
ROOT_COLOR

=end Pod::Coverage

