use warnings;
use strict;

package Curses::Toolkit::Widget;

# ABSTRACT: base class for widgets

use Params::Validate qw(:all);

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
    my $self = bless {
        flags                 => Curses::Toolkit::Object::Flags->new(),
        parent                => undef,
        name                  => 'unknown',
        relatives_coordinates => Curses::Toolkit::Object::Coordinates
            ->new_zero(),
        properties      => {},
        event_listeners => {},
        next_index      => 0,
    }, $class;
    $self->set_sensitive(1);
    $self->set_visible(1);
    return $self;
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
    my ( $self, $name ) = @_;
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

=head2 set_sensitive

  $widget->set_sensitive(1); # set this widget to be sensitive
  $widget->set_sensitive(0); # set this widget to be non sensitive

Sets the sensitivity on/off on the widget. non-sensitive widgets can be seen as "greyed-out"

  input : a boolean
  output : the widget

=cut

sub set_sensitive {
    my $self = shift;
    my ($sensitiveness) = validate_pos( @_, { type => BOOLEAN } );
    $self->set_property( basic => 'sensitive', $sensitiveness ? 1 : 0 );
    return $self;
}

=head2 is_sensitive

Retrieves the sensitivity setting of the widget.

  input : none
  output : true if the widget is sensitive, or false if not

=cut

sub is_sensitive {
    my ($self) = @_;
    return $self->get_property( basic => 'sensitive' );
}

=head2 set_visible

  $widget->set_visible(1); # set this widget to be visible
  $widget->set_visible(0); # set this widget to be non visible

Sets the visibility on/off on the widget. non-visible widgets are not displayed, but they still take space

  input : a boolean
  output : the widget

=cut

sub set_visible {
    my $self = shift;
    my ($visibility) = validate_pos( @_, { type => BOOLEAN } );
    $self->set_property( basic => 'visible', $visibility ? 1 : 0 );
    return $self;
}

=head2 is_visible

Retrieves the visibility setting of the widget.

  input : none
  output : true if the widget is visible, or false if not

=cut

sub is_visible {
    my ($self) = @_;
    return $self->get_property( basic => 'visible' );
}

=head2 set_property

  $widget->set_property('group name', 'property name', 'value');
  $widget->set_property('group name', { name1 => 'value1', ... });

Sets a single property or a whole group of property

properties are arbitrary caracteristics of widgets. They are grouped by
groups. To set a property, you need to specify the group name, then the
property name, then the value name. However you can specify the group name, and
a hash representing this group values.

Returns the widget

=cut

sub set_property {
    my $self = shift;
    my ( $group_name, $property_name, $value ) = validate_pos( @_, 1, 1, 0 );

    if ( ref $property_name eq 'HASH' ) {
        my $group_value = $property_name;
        $self->{property}{$group_name} = $group_value;
    } else {
        $self->{property}{$group_name}{$property_name} = $value;
    }
    return $self;
}

=head2 get_property

  my $value = $widget->get_property('group name', 'property name');
  my $group_hash = $widget->get_property('group name');

Return the property or the group of property of a widget.

=cut

sub get_property {
    my ( $self, $group_name, $property_name ) =
        validate_pos( @_, { isa => 'Curses::Toolkit::Widget' }, { optional => 0 }, { optional => 1 } );
    my $group = $self->{property}{$group_name};
    defined $group or $group = {};
    if ( defined $property_name ) {
        return $group->{$property_name};
    }
    return ( {%$group} );
}

=head2 set_theme_property

  $widget->set_theme_property('property name', 'value');
  $widget->set_theme_property({ name1 => 'value1', ... });

Sets a single theme property or a whole group of theme property

Theme properties are arbitrary theme caracteristics of widgets. They are
 specifically theme oriented properties. To set a theme property, you need to
 specify the property name, then the value name. However you can specify a hash
 representing the values.

Returns the widget;

=cut

sub set_theme_property {
    my $self = shift;
    $self->get_theme->set_property( ref $self, @_ );
    return $self;
}

=head2 get_theme_property

  my $value = $widget->get_theme_property('property name');
  my $hash = $widget->get_theme_property();

Return the theme property or the hash of theme properties of a widget.

=cut

sub get_theme_property {
    my $self = shift;
    $self->get_theme->get_property( ref $self, @_ );
}

# Default theme properties : no theme properties
sub _get_theme_properties_definition {
    my ($self) = @_;
    return {};
}

=head2 add_event_listener

  $widget->add_event_listener($event_listener);

Adds an event listener to the widget. That allows the widget to respond to some
events. You probably don't want to use this method. Please see signal_connect
and possible_signals instead.

  input : a Curses::Toolkit::EventListener
  output : the root window

=cut

sub add_event_listener {
    my $self = shift;
    my ($listener) = validate_pos( @_, { isa => 'Curses::Toolkit::EventListener' } );
    my $index = $self->_get_next_index();
    $self->{event_listeners}->{$index} = $listener;

    #	push @{$self->{event_listeners}}, $listener;
    $listener->_set_widget( $self, $index );
    return $self;
}

=head2 get_event_listeners

  my @listeners = $widget->get_event_listener();

Returns the list of listeners connected to this widget.

  input : none
  output : an ARRAY of Curses::Toolkit::EventListener

=cut

sub get_event_listeners {
    my ($self) = @_;
    return values %{ $self->{event_listeners} };
}

# given its index, unlink the event listener from the widget
# input  : index
# output : the widget

sub _remove_event_listener {
    my ( $self, $index ) = @_;
    delete $self->{event_listeners}{$index};
    return $self;
}

=head2 fire_event

  $widget->fire_event($event, $widget, 1);

Sends an event to the mainloop so it gets dispatched. You probably don't want
to use this method. Please see signal_connect and possible_signals instead.

  input  : a Curses::Toolkit::Event
           optional, a widget. if given, the event will apply on it only
  output : the widget

=cut

sub fire_event {
    my $self        = shift;
    my $root_window = $self->get_root_window()
        or return $self;
    $root_window->fire_event(@_);
    return $self;
}

=head2 draw

This is the method that draws the widget itself.
Default drawing for the widget.
This method doesn't draw anything

=cut

sub draw { return; }

=head2 render

Default rendering method for the widget. Any render method should call draw

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

=head2 set_theme_name

Set a specific display theme name.

  input  : a STRING, name of a class inheriting from Curses::Toolkit::Theme
           a BOOLEAN, if true, recursively sets the themes to the children
  output : the widget

=cut

sub set_theme_name {
    my $self = shift;
    my ( $theme_name, $recurse ) = validate_pos(
        @_, { type => SCALAR },
        { type => BOOLEAN, optional => 1 },
    );
    $self->{theme_name} = $theme_name;
    $self->{theme}      = undef;
    if ($recurse) {
        if ( $self->isa('Curses::Toolkit::Widget::Container') ) {
            my @children = $self->get_children();

            # to avoid rebuilding coordinates at every stage of the recursion,
            # rebuild them only at leaves
            @children
                or $self->rebuild_all_coordinates();
            foreach my $child (@children) {
                $child->set_theme_name( $theme_name, $recurse );
            }
        }
    } else {
        $self->rebuild_all_coordinates();
    }
    return $self;
}

=head2 get_theme_name

Get the theme name used for this widget. If there is none, tries to get it from
the parent. If there is no parent, the default theme name is used

  input  : none
  output : a STRING, name of a class inheriting from Curses::Toolkit::Theme

=cut

sub get_theme_name {
    my ($self) = @_;
    if ( !defined $self->{theme_name} ) {
        my $parent = $self->isa('Curses::Toolkit::Widget::Window') ? $self->get_root_window() : $self->get_parent();
        defined $parent
            and return $parent->get_theme_name();

        # If the widget is floating in the void (not on a root window), return
        # void
        return;
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
    if ( !defined $self->{theme} ) {
        my $theme_name = $self->get_theme_name();
        if ( defined $theme_name ) {
            $self->{theme} = $self->get_theme_name()->new($self);
        } else {
            my $theme_name = Curses::Toolkit->get_default_theme_name();
            return $theme_name->new($self);
        }
    }
    return $self->{theme};
}

=head2 get_window

  my $window = $widget->get_window();

If the widget has been added in a window, get_window() will return this window.
If the widget is not part of window, void returned.

  input  : none
  output : the window in which the widget is (Curses::Toolkit::Widget::Window), or void

=cut

sub get_window {
    my ($self) = @_;
    my $widget = $self;
    while ( !$widget->isa('Curses::Toolkit::Widget::Window') ) {
        $widget = $widget->get_parent();
        defined $widget or return;
    }
    return $widget;
}

=head2 get_root_window

  my $window = $widget->get_root_window();

If the widget has been added in a window, get_root_window() will return the root window.
If the widget is not part of window, void is returned.

  input  : none
  output : the root window (Curses::Toolkit), or void

=cut

sub get_root_window {
    my ($self) = @_;
    my $window = $self->get_window()
        or return;
    my $root_window = $window->get_root_window()
        or return;
    return $root_window;
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
    defined $self->{coordinates}
        and return $self->{coordinates};
    my $parent = $self->get_parent();
    if ( defined $parent ) {
        my $pc = $parent->get_coordinates();
        my $rc = $self->get_relatives_coordinates();
        use Curses::Toolkit::Object::Coordinates;
        my $c = Curses::Toolkit::Object::Coordinates->new(
            x1 => $pc->get_x1() + $rc->get_x1(), y1 => $pc->get_y1() + $rc->get_y1(),
            x2 => $pc->get_x1() + $rc->get_x2(), y2 => $pc->get_y1() + $rc->get_y2(),
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
    defined $self->{relatives_coordinates}
        or die "widget of name '" . $self->get_name() . "' (type '" . ref($self) . "') has no relatives coordinate\n";
    return $self->{relatives_coordinates};
}

=head2 get_visible_shape

Gets the Coordinates of the part of the widget which is visible

  input  : none
  output : the shape (Curses::Toolkit::Object::Coordinates) or void

=cut

sub get_visible_shape {
    my ($self) = @_;
    my $shape  = $self->get_coordinates->clone;
    my $parent = $self->get_parent;
    defined $parent
        and $shape->restrict_to( $parent->get_visible_shape );
    return $shape;
}

=head2 rebuild_all_coordinates

  $widget->rebuild_all_coordinates();

Recompute all the relative coordinates accross the whole window

  input  : none
  output : the widget

=cut

sub rebuild_all_coordinates {
    my ($self) = @_;
    my $widget = $self;

    my $window = $widget->get_window();
    if ( !defined $window ) {

        # if the widget is not part of a window, just return : we can't rebuild
        # the coordinates. We were probably called during the construction of a
        # complicated window, and widgets were created before being added to
        # the window
        return $self;
    }
    $window->_rebuild_children_coordinates();
    $self->needs_redraw();
    return $self;
}

=head2 needs_redraw

  $widget->needs_redraw()

When called, signify to the root window that a redraw is needed. Has an effect
only if a mainloop is active ( see POE::Component::Curses )

  input : none
  output : the widget

=cut

sub needs_redraw {
    my ($self) = @_;
    my $window = $self->get_window();
    defined $window or return $self;
    my $root_window = $window->get_root_window();
    defined $root_window or return $self;
    $root_window->needs_redraw();
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
    defined $self->{curses_handler}
        and return $self->{curses_handler};
    my $parent = $self->get_parent();
    defined $parent
        and return $parent->_get_curses_handler();
    die "couldn't get Curses object from widget (name '" . $self->get_name() . "' type '" . ref($self) . "')";
}

# set forward / backward iterators for transversal travelling

sub _set_iterator {
    my ( $self, $iterator ) = @_;
    $self->{iterator} = $iterator;
    return $self;
}

sub _get_next_brother {
    my ($self) = @_;
    my $iterator = $self->{iterator};
    defined $iterator or return; # there is no brothers
    $iterator->next();
    my $brother_widget = $iterator->value(); # might be undef
    $iterator->prev();
    defined $brother_widget and return $brother_widget;
    return;
}

sub _get_prev_brother {
    my ($self) = @_;
    my $iterator = $self->{iterator};
    defined $iterator or return;             # there is no brothers
    $iterator->prev();
    my $brother_widget = $iterator->value(); # might be undef
    $iterator->next();
    defined $brother_widget and return $brother_widget;
    return;
}

# returns the next available index
# input  : none
# output : index number
sub _get_next_index {
    my ($self) = @_;
    return $self->{next_index}++;
}

=head2 set_modal

=cut

sub set_modal {
    my ($self) = @_;
    my $window = $self->get_window();
    defined $window or return $self;
    my $root_window = $window->get_root_window();
    defined $root_window or return $self;
    $root_window->set_modal_widget($self);
    return $self;
}

=head2 unset_modal

=cut

sub unset_modal {
    my ($self) = @_;
    my $window = $self->get_window();
    defined $window or return $self;
    my $root_window = $window->get_root_window();
    defined $root_window or return $self;
    $root_window->unset_modal_widget();
    return $self;
}


## Focus related stuff

=head2 get_next_focused_widget

  my $next_focused_widget = $widget->get_next_focused_widget();

Returns the widget next in the focus chain

  input : optional, a true value to start searching from $widget
  output : the next focused widget

=cut

sub get_next_focused_widget {
    my ( $self, $dont_avoid_me ) = @_;

    my $next_widget;

    # look down and right
    $next_widget = $self->_recursive_f1( $self, !$dont_avoid_me );
    defined $next_widget and return $next_widget;

    # nothing down and right ? look up and right
    $next_widget = $self->_recursive_f2($self);
    defined $next_widget and return $next_widget;

    # still nothing ? Start from top and look down
    my $window = $self->get_window();
    defined $window or return;
    return $self->_recursive_f1($window);
}

sub _recursive_f1 {
    my ( $self, $widget, $avoid_me ) = @_;

    # Is the widget focusable ?
    unless ($avoid_me) {
        $widget->isa('Curses::Toolkit::Role::Focusable') && $widget->is_focusable()
            and return $widget;
    }

    # does the widget have any children ?
    if ( $widget->isa('Curses::Toolkit::Widget::Container') ) {
        my @children = $widget->get_children();
        if (@children) {
            my $next_widget = $self->_recursive_f1( $children[0] );
            defined $next_widget and return $next_widget;
        }
    }

    # does the widget have a brother ?
    my $brother_widget = $widget->_get_next_brother();
    defined $brother_widget or return;

    return $self->_recursive_f1($brother_widget);
}

sub _recursive_f2 {
    my ( $self, $widget ) = @_;

    # get parent
    my $parent_widget = $widget->get_parent();
    defined $parent_widget or return;

    # is the parent focusable ?
    $parent_widget->isa('Curses::Toolkit::Role::Focusable') && $parent_widget->is_focusable()
        and return $parent_widget;

    # if not, apply f1 on its potential brother
    my $brother_widget = $parent_widget->_get_next_brother();
    if ( defined $brother_widget ) {
        my $next_widget = $self->_recursive_f1($brother_widget);
        defined $next_widget and return $next_widget;
    }

    # still nothing ? call f2
    my $next_widget = $self->_recursive_f2($parent_widget);
    defined $next_widget and return $next_widget;

    return;
}

# =head2 get_previous_focused_widget

#   my $next_previous_widget = $widget->get_previous_focused_widget();

# Returns the widget previous in the focus chain

#   input : optional, a true value to start searching from $widget
#   output : the previous focused widget

# =cut

# sub get_previous_focused_widget {
# 	my ($self, $dont_avoid_me) = @_;

# 	my $prev_widget;
# 	# look down and right
# 	$prev_widget = $self->_recursive_f1($self, !$dont_avoid_me);
# 	defined $prev_widget and return $prev_widget;

# 	# nothing down and right ? look up and right
# 	$prev_widget = $self->_recursive_f2($self);
# 	defined $prev_widget and return $prev_widget;

# 	# still nothing ? Start from top and look down
# 	my $window = $self->get_window();
# 	defined $window or return;
# 	return $self->_recursive_f1($window);
# }


=head2 possible_signals

my @signals = keys $widget->possible_signals();

returns the possible signals that can be used. See S<signal_connect> to bind
signals to action

  input  : none
  output : HASH, keys are signal names, values are signal classes

=cut

# default widget signals
sub possible_signals {
    my ($self) = @_;
    $self->isa('Curses::Toolkit::Role::Focusable')
        and return (
        focus_changed => 'Curses::Toolkit::Signal::Focused',
        focused_in    => 'Curses::Toolkit::Signal::Focused::In',
        focused_out   => 'Curses::Toolkit::Signal::Focused::Out',
        );
    return ();
}

=head2 possible_signals

  # quick
  $widget->signal_connect(
      clicked => sub { do_something }
  );

  # additional args passed
  $widget->signal_connect(
      clicked => \&click_function, $additional, $arguments
  );

  # the corresponding method
  sub click_function {
    my ($event, $widget, $additional, $arguments) = @_;
    print STDERR "the signal came from " . ref($widget) . "\n";
    do_stuff(...)
  }

Connects an action to a signal.

  input  : STRING, signal_name,
           CODEREF, code reference to be executed,
           LIST, additional arguments
  output : HASH, keys are siagnal names, values are signal classes

=cut

sub signal_connect {
    my $self = shift;
    my ( $signal_name, $code_ref, @arguments ) = validate_pos(
        @_, { type => SCALAR },
        { type => CODEREF },
        (0) x ( @_ - 2 ),
    );
    $self->_bind_signal( $signal_name, $code_ref, @arguments );
    return $self;
}

sub _bind_signal {
    my $self = shift;
    my ( $signal_name, $code_ref, @arguments ) = validate_pos(
        @_, { type => SCALAR },
        { type => CODEREF },
        (0) x ( @_ - 2 ),
    );
    my %signals      = $self->possible_signals();
    my $signal_class = $signals{$signal_name};
    defined $signal_class
        or die "signal '$signal_name' doesn't exists for widget of type "
        . ref($self)
        . ". Possible signals are : "
        . join( ', ', keys %signals );

    require UNIVERSAL::require;
    $signal_class->require
        or die $@;
    $self->add_event_listener(
        $signal_class->generate_listener(
            widget    => $self,
            code_ref  => $code_ref,
            arguments => [@arguments],
        )
    );
    return $self;
}

1;
