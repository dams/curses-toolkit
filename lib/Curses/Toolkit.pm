use warnings;
use strict;

package Curses::Toolkit;

# ABSTRACT: a modern Curses toolkit

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

use Curses::Toolkit::Theme;

=head1 SYNOPSIS

  use POE::Component::Curses;
  use Curses::Toolkit::Widget::Window;
  use Curses::Toolkit::Widget::Button;
  
  # spawn a root window
  my $root = POE::Component::Curses->spawn();
    # adds some widget
    $root->add_window(
        my $window = Curses::Toolkit::Widget::Window
          ->new()
          ->set_name('main_window')
          ->add_widget(
            my $button = Curses::Toolkit::Widget::Button
              ->new_with_label('Click Me to quit')
              ->set_name('my_button')
              ->signal_connect(clicked => sub { exit(0); })
          )
          ->set_coordinates( x1 => '20%',   y1 => '20%',
                             x2 => '80%',   y2 => '80%', )
    );

=head1 DESCRIPTION

This module tries to be a modern curses toolkit, based on the Curses module, to
build "semi-graphical" user interfaces easily.

B<WARNING> : This is still in "beta" version, not all the features are
implemented, and the API may change. However, most of the components are there,
and things should not change that much in the future... Still, don't use it in
production, and don't consider it stable.

L<Curses::Toolkit> is meant to be used with a mainloop, which is not part of this
module. I recommend you L<POE::Component::Curses>, which is probably what you
want. L<POE::Component::Curses> uses Curses::Toolkit, but provides a mainloop
and handles keyboard, mouse, timer and other events, whereas Curses::Toolkit is
just the drawing library. See the example above. the C<spawn> method returns a
L<Curses::Toolkit> object, which you can call methods on.

If you already have a mainloop or if you don't need it, you might want
to use Curses::Toolkit directly. But again, it's probably not what you want to
use. In this case you would do something like :

  use Curses::Toolkit;

  # using Curses::Toolkit without any event loop
  my $root = Curses::Toolkit->init_root_window();
  my $window = Curses::Toolkit::Widget::Window->new();
  $root->add($window);
  ...
  $root->render

=head1 TUTORIAL

If you are new with C<Curses::Toolkit>, I suggest you go through the tutorial. You can find it here:

L<Curses::Toolkit::Tutorial> (not yet done!)

=head1 WIDGETS

Curses::Toolkit is based on a widget model, inspired by Gtk. I suggest you read
the POD of the following widgets :

=over

=item L<Curses::Toolkit::Widget::Window>

Use this widget to create a window. It's the first thing to do once you have a root_window

=item L<Curses::Toolkit::Widget>

Useful to read, it contains the common methods of all the widgets

=item L<Curses::Toolkit::Widget::Label>

To display simple text, with text colors and attributes

=item L<Curses::Toolkit::Widget::Button>

Simple text button widget to interact with the user

=item L<Curses::Toolkit::Widget::GenericButton>

A button widget that can contain anything, not just a label

=item L<Curses::Toolkit::Widget::Entry>

To input text from the user

=item L<Curses::Toolkit::Widget::VBox>

To pack widgets vertically, thus building complex layouts

=item L<Curses::Toolkit::Widget::HBox>

To pack widgets horizontally, thus building complex layouts

=item L<Curses::Toolkit::Widget::Border>

Add a simple border around any widget

=item L<Curses::Toolkit::Widget::HPaned>

To pack 2 widgets horizontally with a flexible gutter

=item L<Curses::Toolkit::Widget::VPaned>

To pack 2 widgets vertically with a flexible gutter

=item L<Curses::Toolkit::Widget::HScrollBar>

Not yet implemented

=item L<Curses::Toolkit::Widget::VScrollBar.pm>

Not yet implemented

=item L<Curses::Toolkit::Widget::HProgressBar>

An horizontal progress bar widget

=item L<Curses::Toolkit::Widget::HProgressBar>

A vertical progress bar widget

=back

For reference, here are the various hierarchy of the objects/concepts of the
toolkit you might have to use :

=head1 WIDGETS HIERARCHY

This is the inheritance hierarchy of the widgets of the toolkit :

  Curses::Toolkit::Widget
  |
  +-- Curses::Toolkit::Widget::Window
  |   |
  |   +-- Curses::Toolkit::Widget::Window::Dialog
  |       |
  |       + Curses::Toolkit::Widget::Window::Dialog::About
  |
  +-- Curses::Toolkit::Widget::Label
  |
  +-- Curses::Toolkit::Widget::Entry
  |
  +-- Curses::Toolkit::Widget::Scrollbar
  |   |
  |   +-- Curses::Toolkit::Widget::HScrollbar
  |   |
  |   +-- Curses::Toolkit::Widget::VScrollbar
  |
  +-- Curses::Toolkit::Widget::Container
      |
      +-- Curses::Toolkit::Widget::HBox
      |
      +-- Curses::Toolkit::Widget::VBox
      |
      +-- Curses::Toolkit::Widget::Paned
      |   |
      |   +-- Curses::Toolkit::Widget::HPaned
      |   |
      |   +-- Curses::Toolkit::Widget::VPaned
      |
      +-- Curses::Toolkit::Widget::Bin
          |
          +-- Curses::Toolkit::Widget::Border
              |
              +-- Curses::Toolkit::Widget::Button
              |
              +-- Curses::Toolkit::Widget::GenericButton
              |
              +-- Curses::Toolkit::Widget::ProgressBar
                  |
                  +-- Curses::Toolkit::Widget::HProgressBar
                  |
                  +-- Curses::Toolkit::Widget::VProgressBar

=head1 SIGNALS HIERARCHY

This is the inheritance hierarchy of the signals :

  Curses::Toolkit::Signal
  |
  +-- Curses::Toolkit::Signal::Clicked
  |
  +-- Curses::Toolkit::Signal::Content
  |   |
  |   +-- Curses::Toolkit::Signal::Content::Changed
  |
  +-- Curses::Toolkit::Signal::Focused
      |
      +-- Curses::Toolkit::Signal::Focused::In
      |
      +-- Curses::Toolkit::Signal::Focused::Out

=head1 THEMES HIERARCHY

This is the inheritance hierarchy of the themes :

  Curses::Toolkit::Theme
  |
  +-- Curses::Toolkit::Theme::Default
      |
      +-- Curses::Toolkit::Theme::Default::Color
      |
      +-- Curses::Toolkit::Theme::Default::Color::Pink
      |
      +-- Curses::Toolkit::Theme::Default::Color::Yellow

=head1 OBJECTS HIERARCHY

This is the list of objects of the toolkit :

  Curses::Toolkit::Object
  |
  +-- Curses::Toolkit::Object::Coordinates
  |
  +-- Curses::Toolkit::Object::MarkupString
  |
  +-- Curses::Toolkit::Object::Shape

=head1 ROLES HIERARCHY

For now there is only one role

  Curses::Toolkit::Role::Focusable

=head1 TYPES HIERARCHY

For now there is only one types class :

  Curses::Toolkit::Types

=head1 CLASS METHODS

=head2 init_root_window

  my $root = Curses::Toolkit->init_root_window();

Initialize the Curses environment, and return an object representing it. This
is not really a constructor, because you can't have more than one
Curses::Toolkit object for one Curses environment. Think of it more like a
service.

  input  : theme_name        : optional, the name of the theme to use as default display theme
           mainloop          : optional, the mainloop object that will be used for event handling
           quit_key          : the key used to quit the whole application. Default to 'q'. If set to undef, it's disabled
           switch_key        : the key used to switch between windows. Default to 'r'. If set to undef, it's disabled
           test_environment  : optional, a hashref, if set, Curses::Toolkit will be in test mode
  output : a Curses::Toolkit object

=cut

sub init_root_window {
    my $class = shift;

    my %params = validate(
        @_,
        {   theme_name => {
                type     => SCALAR,
                optional => 1,
            },
            mainloop => { optional => 1 },
            quit_key => {
                type    => SCALAR,
                default => 'q',
            },
            switch_key => {
                type    => SCALAR,
                default => 'r',
            },
            test_environment => {
                type    => HASHREF,
                optional => 1,
            },
        }
    );

    # get the Curses handler
    use Curses;
    my $curses_handler = Curses->new();

    # already done ?
    #     raw();
    #     cbreak();
    #     noecho();
    #     $curses_handler->keypad(1);

    if (has_colors) {
        start_color();
    }

    eval { Curses->can('NCURSES_MOUSE_VERSION') && ( NCURSES_MOUSE_VERSION() >= 1 ) };

    my $old_mouse_mask;
    my $mouse_mask = mousemask( ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, $old_mouse_mask );

    use Curses::Toolkit::Theme::Default;
    use Curses::Toolkit::Theme::Default::Color::Yellow;
    use Curses::Toolkit::Theme::Default::Color::Pink;
    use Curses::Toolkit::Theme::Default::Color::BlueWhite;

    use Tie::Array::Iterable;
    $params{theme_name} ||= Curses::Toolkit->get_default_theme_name();
    my @windows = ();
    my $self    = bless {
        initialized     => 1,
        curses_handler  => $curses_handler,
        windows         => Tie::Array::Iterable->new(@windows),
        theme_name      => $params{theme_name},
        mainloop        => $params{mainloop},
        last_stack      => 0,
        event_listeners => [],
        window_iterator => undef,
        test_environment => $params{test_environment},
    }, $class;
    $self->_recompute_shape();

    use Curses::Toolkit::EventListener;

    # add a default listener that listen to any Shape event
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Shape' => sub { 1; },
            },
            code => sub {
                my ( $screen_h, $screen_w );
                $self->_recompute_shape();

                # for now we rebuild all coordinates
                foreach my $window ( $self->get_windows() ) {
                    $window->rebuild_all_coordinates();
                }
            },
        )
    );
    if ( defined $params{quit_key} ) {
        $self->add_event_listener(
            Curses::Toolkit::EventListener->new(
                accepted_events => {
                    'Curses::Toolkit::Event::Key' => sub {
                        my ($event) = @_;
                        $event->{type} eq 'stroke' or return 0;
                        lc $event->{params}{key} eq $params{quit_key} or return 0;
                    },
                },
                code => sub {
                    exit;
                },
            )
        );
    }
    if ( defined $params{switch_key} ) {
        $self->add_event_listener(
            Curses::Toolkit::EventListener->new(
                accepted_events => {
                    'Curses::Toolkit::Event::Key' => sub {
                        my ($event) = @_;
                        $event->{type} eq 'stroke' or return 0;
                        lc $event->{params}{key} eq $params{switch_key} or return 0;
                    },
                },
                code => sub {
                    my ( $event, $widget ) = @_;
                    defined $self->{window_iterator}
                        or return;
                    my $window = $widget->{window_iterator}->next();
                    if ( !defined $window ) {
                        $widget->{window_iterator}->to_start();
                        $window = $widget->{window_iterator}->value();
                    }

                    # get the currently focused widget, unfocus it
                    my $current_focused_widget = $self->get_focused_widget();
                    if ( defined $current_focused_widget && $current_focused_widget->can('set_focus') ) {
                        $current_focused_widget->set_focus(0);
                    }
                    $window->bring_to_front();

                    # focus the window or one of its component
                    my $next_focused_widget =
                        $window->get_next_focused_widget(1); # 1 means "consider if $window is focusable"
                    defined $next_focused_widget
                        and $next_focused_widget->set_focus(1);
                },
            )
        );
    }

    # key listener for TAB
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Key' => sub {
                    my ($event) = @_;
                    $event->{type} eq 'stroke' or return 0;
                    $event->{params}{key} eq '<^I>' or return 0;
                },
            },
            code => sub {
                my $focused_widget = $self->get_focused_widget();
                if ( defined $focused_widget ) {
                    my $next_focused_widget = $focused_widget->get_next_focused_widget();
                    defined $next_focused_widget
                        and $next_focused_widget->set_focus(1);
                } else {
                    my $focused_window      = $self->get_focused_window();
                    my $next_focused_widget = $focused_window->get_next_focused_widget();
                    defined $next_focused_widget
                        and $next_focused_widget->set_focus(1);
                }
            },
        )
    );

    # key listener for BACK TAB
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Key' => sub {
                    my ($event) = @_;
                    $event->{type} eq 'stroke' or return 0;
                    $event->{params}{key} eq 'KEY_BTAB' or return 0;
                },
            },
            code => sub {

                #  my $focused_widget = $self->get_focused_widget();
                #  if (defined $focused_widget) {
                #      my $prev_focused_widget = $focused_widget->get_prev_focused_widget();
                #      defined $prev_focused_widget and
                #        $prev_focused_widget->set_focus(1);
                #  } else {
                #      my $focused_window = $self->get_focused_window();
                #      my $prev_focused_widget = $focused_window->get_prev_focused_widget();
                #      defined $prev_focused_widget and
                #        $prev_focused_widget->set_focus(1);
                #  }
            },
        )
    );

    return $self;
}

sub get_default_theme_name {
    my ($class) = @_;
    return (
        has_colors()
        ? 'Curses::Toolkit::Theme::Default::Color::BlueWhite'
        : 'Curses::Toolkit::Theme::Default'
    );

    # 'Curses::Toolkit::Theme::Default::Color::Yellow'
    # 'Curses::Toolkit::Theme::Default::Color::Pink'
}


# destroyer
DESTROY {
    my ($obj) = @_;

    # ending Curses
    ref($obj) eq 'Curses::Toolkit'
        and Curses::endwin;
}


=head1 METHODS

=head2 get_theme_name

  my $theme_name = $root_window->get_theme_name();

Return the theme associated with the root window. Typically used to get a
usable default theme name. Use that instead of hard-coding
'Curses::Toolkit::Theme::Default'

=cut

sub get_theme_name {
    my ($self) = @_;
    return $self->{theme_name};
}


=head2 add_event_listener

  $root->add_event_listener($event_listener);

Adds an event listener to the root window. That allows the root window to
respond to some events

  input : a Curses::Toolkit::EventListener
  output : the root window

=cut

sub add_event_listener {
    my $self = shift;
    my ($listener) = validate_pos( @_, { isa => 'Curses::Toolkit::EventListener' } );
    push @{ $self->{event_listeners} }, $listener;
    return $self;
}

=head2 get_event_listeners

  my @listeners = $root->get_event_listener();

Returns the list of listeners connected to the root window.

  input : none
  output : an ARRAY of Curses::Toolkit::EventListener

=cut

sub get_event_listeners {
    my ($self) = @_;
    return @{ $self->{event_listeners} };
}

=head2 get_focused_widget

  my $widget = $root->get_focused_widget();

Returns the widget currently focused. Warning, the returned widget could well
be a window.

  input : none
  output : a Curses::Toolkit::Widget or void

=cut

sub get_focused_widget {
    my ($self) = @_;
    my $window = $self->get_focused_window();
    defined $window or return;
    return $window->get_focused_widget();
}

=head2 get_focused_window

  my $window = $root->get_focused_window();

Returns the window currently focused.

  input : none
  output : a Curses::Toolkit::Widget::Window or void

=cut

sub get_focused_window {
    my ($self) = @_;
    my @windows = $self->get_windows();
    @windows or return;
    my $window =
        ( sort { $b->get_property( window => 'stack' ) <=> $a->get_property( window => 'stack' ) } @windows )[0];
    return $window;
}

=head2 get_focused_window

  my $window = $root->get_nexd_window();

Returns the next window.

  input : none
  output : a Curses::Toolkit::Widget::Window or void

=cut

# sub get_next_window {
#     my ($self) = @_;
#     my $iterator = $window->{window_iterator}
#       or return;
#     $iterator->next();
#     my $sister_window = $iterator->value(); # might be undef
#     $iterator->prev();
#     defined $sister_window and return $sister_window;
#     return;
# }

=head2 set_mainloop

  $root->set_mainloop($mainloop)

Sets the mainloop object to be used by the Curses::Toolkit root object. The
mainloop object will be called when a new event has to be registered. The
mainloop object is in charge to listen to the events and call $root->dispatch_event()

  input  : a mainloop object
  output : the Curses::Toolkit object

=cut

sub set_mainloop {
    my $self = shift;
    my ($mainloop) = validate_pos( @_, { optional => 0 } );
    $self->{mainloop} = $mainloop;
    return $self;
}

=head2 get_mainloop

  my $mainloop = $root->get_mainloop()

Return the mainloop object associated to the root object. Might be undef if no
mainloop were associated.

  input : none
  output : the mainloop object, or undef

=cut

sub get_mainloop {
    my ($self) = @_;
    return $self->{mainloop};
}

=head2 get_shape

  my $coordinate = $root->get_shape();

Returns a coordinate object that represents the size of the root window.

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_shape {
    my ($self) = @_;
    return $self->{shape};
}

=head2 add_window

  my $window = Curses::Toolkit::Widget::Window->new();
  $root->add_window($window);

Adds a window on the root window. Returns the root window

  input : a Curses::Toolkit::Widget::Window object
  output : the root window

=cut

sub add_window {
    my $self = shift;
    my ($window) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget::Window' } );
    $window->_set_curses_handler( $self->{curses_handler} );
    $window->set_theme_name( $self->{theme_name} );
    $window->set_root_window($self);
    $self->bring_window_to_front($window);

    # in case the window has proportional coordinates depending on the root window
    # TODO : do that only if window has proportional coordinates, not always
    $window->rebuild_all_coordinates();
    push @{ $self->{windows} }, $window;
    $self->{window_iterator} ||= $self->{windows}->forward_from();
    $self->needs_redraw();
    return $self;
}

=head2 bring_window_to_front()

  $root_window->bring_window_to_front($window)

Brings the window to front

  input : a Curses::Toolkit::Widget::Window
  output : the root window

=cut

sub bring_window_to_front {
    my $self = shift;
    my ($window) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget::Window' } );
    $self->{last_stack}++;
    $window->set_property( window => 'stack', $self->{last_stack} );
    my $last_stack = $self->{last_stack};
    $last_stack % 5 == 0
        and $self->{last_stack} = $self->_cleanup_windows_stacks();

    $self->needs_redraw();
    return $self;
}

sub _cleanup_windows_stacks {
    my ($self) = @_;

    my @sorted_windows =
        sort { $a->get_property( window => 'stack' ) <=> $b->get_property( window => 'stack' ) } $self->get_windows();

    foreach my $idx ( 0 .. @sorted_windows - 1 ) {
        $sorted_windows[$idx]->set_property( window => 'stack', $idx );
    }
    return @sorted_windows - 1;
}

=head2 needs_redraw

  $root->needs_redraw()

When called, signify to the root window that a redraw is needed. Has an effect
only if a mainloop is active ( see POE::Component::Curses )

  input : none
  output : the root window

=cut

sub needs_redraw {
    my ($self) = @_;
    my $mainloop = $self->get_mainloop();
    defined $mainloop or return $self;
    $mainloop->needs_redraw();
    return $self;
}

=head2 get_windows

  my @windows = $root->get_windows();

Returns the list of windows loaded

  input : none
  output : ARRAY of Curses::Toolkit::Widget::Window

=cut

sub get_windows {
    my ($self) = @_;
    return @{ $self->{windows} };
}

=head2 set_modal_widget

Set a widget to be modal

  input  : a widget
  output : the root window

=cut

sub set_modal_widget {
    my $self = shift;
    my ($widget) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' } );
    $self->{_modal_widget} = $widget;
    return $self;
}

=head2 unset_modal_widget

Unset the widget to be modal

  input  : none
  output : the root window

=cut

sub unset_modal_widget {
    my $self = shift;
    $self->{_modal_widget} = undef;
    return;
}

=head2 get_modal_widget

returns the modal widget, or void

  input  : none
  output : the modal widget or void

=cut

sub get_modal_widget {
    my ($self) = @_;

    my $modal_widget = $self->{_modal_widget};
    defined $modal_widget or return;
    return $modal_widget;
}

=head2 show_all

  $root->show_all();

Set visibility property to true for every element. Returns the root windows

  input : none
  output : the root window

=cut

sub show_all {
    my ($self) = @_;
    foreach my $window ( $self->get_windows() ) {
        $window->show_all();
    }
    return $self;
}


=head2 render

  $root->render();

Build everything in the buffer. You need to call 'display' after that to display it

  input : none
  output : the root window

=cut


sub render {
    my ($self) = @_;

    $self->{test_environment}
      or $self->{curses_handler}->erase();

    if (!defined $self->{_root_theme}) {
        $self->{_root_theme} = $self->get_theme_name->new(Curses::Toolkit::Widget::Window->new());
        $self->{_root_theme}->_set_colors($self->{_root_theme}->ROOT_COLOR, $self->{_root_theme}->ROOT_COLOR);
    }
    my $root_theme = $self->{_root_theme};

    my $c = $self->{shape};
    my $str = ' ' x ($c->get_x2() - $c->get_x1());
    $self->{curses_handler}->attron($root_theme->_get_color_pair);
    foreach my $y ( $c->get_y1() .. $c->get_y2() - 1 ) {
        $self->{curses_handler}->addstr( $y, $c->get_x1(), $str );
    }
    
    foreach my $window ( sort { $a->get_property( window => 'stack' ) <=> $b->get_property( window => 'stack' ) }
        $self->get_windows() )
    {
        $window->render();
    }
    return $self;
}

=head2 display

  $root->display();

Refresh the screen.

  input  : none
  output : the root window

=cut

sub display {
    my ($self) = @_;
    $self->{curses_handler}->refresh();
    return $self;
}

=head2 dispatch_event

  my $event = Curses::Toolkit::Event::SomeEvent->new(...)
  $root->dispatch_event($event);

Given an event, dispatch it to the appropriate widgets / windows, or to the
root window. You probably don't want to use this method directly. Use Signals instead.

  input  : a Curses::Toolkit::Event
           optional, a widget. if given, the event dispatching will start with this wisget (and not the focused one)
  output : true if the event were handled, false if not

=cut

sub dispatch_event {
    my $self = shift;
    my ( $event, $widget ) = validate_pos(
        @_, { isa => 'Curses::Toolkit::Event' },
        { isa => 'Curses::Toolkit::Widget', optional => 1 },
    );

    if ( !defined $widget ) {
        $widget = $self->get_modal_widget();
        defined $widget and $self->unset_modal_widget();
    }
    $widget ||= $event->get_matching_widget();
    defined $widget or return;

    while (1) {
        foreach my $listener ( grep { $_->is_enabled() } $widget->get_event_listeners() ) {
            if ( $listener->can_handle($event) ) {
                $listener->send_event( $event, $widget );
                $event->can_propagate()
                    or return 1;
            }
        }
        $event->restricted_to_widget()
            and return;
        if ( $widget->isa('Curses::Toolkit::Widget::Window') ) {
            $widget = $widget->get_root_window();
        } elsif ( $widget->isa('Curses::Toolkit::Widget') ) {
            $widget = $widget->get_parent();
        } else {
            return;
        }
        defined $widget or return;
    }
    return;
}

=head2 fire_event

  $widget->fire_event($event, $widget);

Sends an event to the mainloop so it gets dispatched. You probably don't want
to use this method.

  input  : a Curses::Toolkit::Event
           optional, a widget. if given, the event dispatching will start with this widget (and not the focused one)
  output : the root_window

=cut

sub fire_event {
    my $self = shift;
    my ( $event, $widget ) = validate_pos(
        @_, { isa => 'Curses::Toolkit::Event' },
        { isa => 'Curses::Toolkit::Widget', optional => 1 },
    );
    my $mainloop = $self->get_mainloop();
    defined $mainloop or return $self;
    $mainloop->stack_event( $event, $widget );
    return $self;
}

=head2 add_delay

Has an effect only if a mainloop is active ( see POE::Component::Curses )

  $root_window->add_delay($seconds, \&code, @args)
  $root_window->add_delay(5, sub { print "wow, 5 seconds wasted, dear $_[0]\n"; }, $name);

Add a timer that will execute the \&code once, in $seconds seconds. $seconds
can be a fraction. @args will be passed to the code reference

  input  : number of seconds
           a code reference
           an optional list of arguments to be passed to the code reference
  output : a timer unique identifier or void

=cut

sub add_delay {
    my $self     = shift;
    my $mainloop = $self->get_mainloop();
    defined $mainloop or return;
    $mainloop->add_delay(@_);
    return;
}

# ## Private methods ##

# # event_handling

# my @supported_events = (qw(Curses::Toolkit::Event::Shape));
# sub _handle_event {
#     my ($self, $event) = @_;
#     use List::MoreUtils qw(any);
#     if ( any { $event->isa($_) } @supported_events ) {
#         my $method_name = '_event_' . lc( (split('::|_', ref($event)))[-1] ) . '_' .  $event->get_type();
#         if ($self->can($method_name)) {
#             return $self->$method_name();
#         }
#     }
#     # event failed being applied
#     return 0;
# }

# core event handling for Curses::Toolkit::Event::Shape event of type 'change'
sub _event_shape_change {
    my ($self) = @_;

    my ( $screen_h, $screen_w );
    $self->_recompute_shape();

    # for now we rebuild all coordinates
    foreach my $window ( $self->get_windows() ) {
        $window->rebuild_all_coordinates();
    }

    # for now rebuild everything
    #    my $mainloop = $self->get_mainloop();
    #    if (defined $mainloop) {
    #        $mainloop->needs_redraw();
    #    }

    # event suceeded
    return 1;

}

sub _recompute_shape {
    my ($self) = @_;
    use Curses::Toolkit::Object::Coordinates;
    my ( $screen_h, $screen_w );
    use Curses;
    if ($self->{test_environment}) {
        $screen_h = $self->{test_environment}->{screen_h};
        $screen_w = $self->{test_environment}->{screen_w};
    } else {
        endwin;
        $self->{curses_handler}->getmaxyx( $screen_h, $screen_w );
    }
    use Curses::Toolkit::Object::Shape;
    $self->{shape} ||= Curses::Toolkit::Object::Shape->new_zero();
    $self->{shape}->_set(
        x2 => $screen_w,
        y2 => $screen_h,
    );
    return $self;
}

sub _rebuild_all {
    my ($self) = @_;
    foreach my $window ( $self->get_windows() ) {
        $window->rebuild_all_coordinates();
    }
    return $self;
}

1;

=head1 BUGS

Please report any bugs or feature requests to
C<bug-curses-toolkit at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Curses-Toolkit>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Curses::Toolkit

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Curses-Toolkit>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Curses-Toolkit>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Curses-Toolkit>

=item * Search CPAN

L<http://search.cpan.org/dist/Curses-Toolkit>

=back

