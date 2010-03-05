use warnings;
use strict;

package Curses::Toolkit::Widget::Window;

# ABSTRACT: a window

use parent qw(Curses::Toolkit::Widget::Border);

use Params::Validate qw(:all);

use List::MoreUtils qw(any none);
use List::Util qw(min sum max);

use Curses::Toolkit::EventListener;

=head1 Appearence


  +-[ title ]------------+
  |                      |
  |                      |
  |                      |
  |                      |
  |                      |
  |                      |
  |                      |
  |                      |
  +----------------------#

=head1 DESCRIPTION

This is a window widget. This widget is important, as it's the only one that
you can add on the root window. So all your graphical interface should be
contained in one or more window.

=head1 SYNOPSIS

  # create a window in the center of the screen
  my $window = Curses::Toolkit::Widget::Window
    ->new()
    ->set_name('main_window')
    ->set_title('This is a title');
    ->set_coordinates(x1 => '25%', y1 => '25%'
                      x2 => '75%', y2 => '75%');

  # create a fullscreen window
  my $window = Curses::Toolkit::Widget::Window
    ->new()
    ->set_name('main_window')
    ->set_theme_property(border_width => 0); # set no border
    ->set_coordinates(x1 => 0, y1 => 0
                      x2 => '100%', y2 => '100%');

  # add one widget to the window. You can add only one widget to the window.
  # See L<Curses::Toolkit::Widget::VBox> and <Curses::Toolkit::Widget::HBox> to
  # pack widgets
  $window->add_widget($vbox)

  # add the window to the root window. See L<Curses::Toolkit> to see how to
  # spawn a root window
  $root->add_window($window);


=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Window

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);

    # set window stack by default
    $self->set_property( window => stack     => -1 );
    $self->set_property( window => resizable => 1 );

    # set_default title
    $self->set_title('');
    $self->set_type('normal');
    $self->{_title_offset}              = 0;
    $self->{_title_animation_direction} = '';

    #	$self->set_focused_widget($self);

    # listen to the Mouse Click for focus switch
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Mouse::Click' => sub {
                    my ($event) = @_;
                    $event->{type}   eq 'clicked' or return 0;
                    $event->{button} eq 'button1' or return 0;
                    return 1;
                },
            },
            code => sub {
                my ( $event, $window ) = @_;

                # get the root window
                my $root_window = $window->get_root_window();
                defined $root_window or return;

                # get the currently focused widget, unfocus it
                my $current_focused_widget = $root_window->get_focused_widget();
                if ( defined $current_focused_widget && $current_focused_widget->can('set_focus') ) {
                    $current_focused_widget->set_focus(0);
                }

                # bring the window to the front
                $window->bring_to_front();

                # focus the window or one of its component
                my $next_focused_widget =
                    $window->get_next_focused_widget(1); # 1 means "consider if $window is focusable"
                defined $next_focused_widget
                    and $next_focused_widget->set_focus(1);
                return;
            },
        )
    );

    # listen to the Mouse for moving the window
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Mouse::Click' => sub {
                    my ($event) = @_;
                    $event->{button} eq 'button1' or return 0;
                    $self->{_move_pressed} && $event->{type} eq 'released'
                        and return 1;
                    my $c  = $event->{coordinates};
                    my $wc = $self->get_coordinates();
                    !$self->{_move_pressed} && $event->{type} eq 'pressed' && $c->get_y1() == $wc->get_y1()
                        and return 1;
                    return 0;
                },
            },
            code => sub {
                my ( $event, $window ) = @_;

                if ( $self->{_move_pressed} ) {

                    # means we released it
                    $window->unset_modal();
                    my $c  = $event->{coordinates};                 # event coord
                    my $oc = $self->{_move_coord};                  # click-origin coord
                    my $wc = $window->get_coordinates();            # window coord
                    my $rc = $self->get_root_window()->get_shape(); # root coord
                    $wc += {
                        x1 => $c->get_x1() - $oc->get_x1(), x2 => $c->get_x1() - $oc->get_x1(),
                        y1 => $c->get_y1() - $oc->get_y1(), y2 => $c->get_y1() - $oc->get_y1(),
                    };
                    $wc->get_y1() < 0
                        and $wc->translate_down( $wc->get_y1() );
                    $wc->get_y1() > $rc->height() - 1
                        and $wc->translate_up( $wc->get_y1() - $rc->height() + 1 );
                    $wc->get_x1() < -$wc->width() + 1
                        and $wc->translate_right( -$wc->width() + 1 - $wc->get_x1() );
                    $wc->get_x1() > $rc->width() - 1
                        and $wc->translate_left( -$wc->get_x1() - $rc->width() + 1 );

                    $window->set_coordinates($wc);
                    $window->needs_redraw();
                    $self->{_move_pressed} = 0;
                    $self->{_move_coord}   = undef;
                } else {

                    # means we pressed it
                    $window->set_modal();
                    $self->{_move_pressed} = 1;
                    $self->needs_redraw();
                    $self->{_move_coord} = $event->{coordinates};
                }
                return;
            },
        )
    );

    # listen to the Mouse for resizing
    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Mouse::Click' => sub {
                    my ($event) = @_;
                    $event->{button} eq 'button1' or return 0;
                    $self->{_resize_pressed} && $event->{type} eq 'released'
                        and return 1;
                    my $c  = $event->{coordinates};
                    my $wc = $self->get_coordinates();
                          !$self->{_resize_pressed}
                        && $event->{type} eq 'pressed'
                        && $c->get_x2() == $wc->get_x2() - 1
                        && $c->get_y2() == $wc->get_y2() - 1
                        and return 1;
                    return 0;
                },
            },
            code => sub {
                my ( $event, $window ) = @_;

                if ( $self->{_resize_pressed} ) {

                    # means we released it
                    $window->unset_modal();
                    my $c  = $event->{coordinates};
                    my $wc = $window->get_coordinates();
                    $wc->set( x2 => $c->get_x2() + 1, y2 => $c->get_y2() + 1 );
                    $window->set_coordinates($wc);
                    $window->needs_redraw();
                    $self->{_resize_pressed} = 0;
                } else {

                    # means we pressed it
                    $window->set_modal();
                    $self->needs_redraw();
                    $self->{_resize_pressed} = 1;
                }
                return;
            },
        )
    );
    return $self;
}

=head2 set_title

Set the title of the window

  input  : the title
  output : the window widget

=cut

sub set_title {
    my $self = shift;
    my ($title) = validate_pos(
        @_,
        {   type => SCALAR,
        }
    );
    $self->{title} = $title;
    return $self;
}

=head2 get_title

Get the title of the window

  input  : none
  output : the window title

=cut

sub get_title {
    my ($self) = @_;
    return $self->{title};
}

=head2 set_coordinates

Set the coordinates (see L<Curses::Toolkit::Object::Coordinates> )

You can also set coordinates in percent of the root window width / height :

  input  : x1 : top left x (can be in percent ( ex : '42%' ) )
           y1 : top left y (can be in percent ( ex : '42%' ) )
           x2 : right bottom x (can be in percent ( ex : '42%' ) )
           y2 : right bottom y (can be in percent ( ex : '42%' ) )
    OR
  input  : x1 : top left x (can be in percent ( ex : '42%' ) )
           y1 : top left y (can be in percent ( ex : '42%' ) )
           width : width (can be in percent ( ex : '42%' ) )
           height : heigth (can be in percent ( ex : '42%' ) )
    OR
  input  : x1 : sub { ... } # returns top left x
           y1 : sub { ... } # returns top left y
           x2 : sub { ... } # returns right bottom x
           y2 : sub { ... } # returns right bottom y
    OR
  input  : a Curses::Toolkit::Object::Coordinates object

=cut

sub set_coordinates {
    my $self = shift;
    use Curses::Toolkit::Object::Coordinates;
    use Data::Dumper;
    if ( !ref( $_[0] ) ) {
        my %params = @_;
        foreach my $x (qw(x1 x2)) {
            if ( $params{$x} =~ /^(.+)%$/ ) {
                my $percent = $1;
                $params{$x} = sub {
                    return $self->get_root_window()
                        ? sprintf( "%.0f", $self->get_root_window()->get_shape()->width() * $percent / 100 )
                        : 0;
                };
            }
        }
        foreach my $y (qw(y1 y2)) {
            if ( $params{$y} =~ /^(.+)%$/ ) {
                my $percent = $1;
                $params{$y} = sub {
                    return $self->get_root_window()
                        ? sprintf( "%.0f", $self->get_root_window()->get_shape()->height() * $percent / 100 )
                        : 0;
                };
            }
        }
        if ( defined $params{width} && $params{width} =~ /^(.+)%$/ ) {
            my $percent = $1;
            $params{x2} = sub {
                my ($coord) = @_;
                $coord->get_x1()
                    + ( $self->get_root_window() and $self->get_root_window()->get_shape()->width() * $percent / 100 );
            };
            delete $params{width};
        }
        if ( defined $params{height} && $params{height} =~ /^(.+)%$/ ) {
            my $percent = $1;
            $params{y2} = sub {
                my ($coord) = @_;
                $coord->get_y1()
                    + ( $self->get_root_window() and $self->get_root_window()->get_shape()->height() * $percent / 100 );
            };
            delete $params{height};
        }
        $self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(%params);
    } else {
        $self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
    }
    $self->_set_relatives_coordinates( $self->{coordinates} );

    # needs to take care of rebuilding coordinates from top to bottom
    $self->rebuild_all_coordinates();
    return $self;
}

=head2 set_root_window

Sets the root window ( the root toolkit object) to which this window is added 

  input  : the root toolkit object (Curses::Toolkit)
  output : the window

=cut

sub set_root_window {
    my ( $self, $root_window ) = @_;
    $self->{root_window} = $root_window;
    return $self;
}

=head2 get_root_window

Get the root window

  input  : none
  output : the root toolkit object (Curses::Toolkit)

=cut

sub get_root_window {
    my ($self) = @_;
    return $self->{root_window};
}

=head2 bring_to_front()

  $window->bring_to_front()

Bring the window to front

  input : none
  output : the window widget

=cut

sub bring_to_front {
    my ($self) = @_;
    my $root_window = $self->get_root_window();
    defined $root_window or return;
    $root_window->bring_window_to_front($self);
    return $self;
}

=head2 bring_to_back()

  $window->bring_to_back()

Bring the window to the back

  input : none
  output : none

=cut

# sub bring_to_front {
# 	my ($self) = @_;
# 	$self->
# }

=head2 set_focused_widget

  $window->set_focused_widget($widget);

Set the widget that has focus.

  input : a Curses::Toolkit::Widget that is into this window
  output : the window

=cut

sub set_focused_widget {
    my $self = shift;
    my ($widget) = validate_pos(
        @_,
        {   isa       => 'Curses::Toolkit::Widget',
            callbacks => {
                'must be focusable' => sub { $_[0]->isa('Curses::Toolkit::Role::Focusable') }
            }
        }
    );
    my $current_focused_widget = $self->get_focused_widget();
    if ( defined $current_focused_widget && $current_focused_widget->can('set_focus') ) {
        $current_focused_widget->set_focus(0);
    }
    $self->{focused_widget} = $widget;
    return $self;
}

=head2 get_focused_widget

  my $widget = $window->get_focused_widget();

Gets the focused widget.

  input : none
  output : the focused Curses::Toolkit::Widget

=cut

sub get_focused_widget {
    my ($self) = @_;
    my $focused_widget = $self->{focused_widget};
    if ( defined $focused_widget && $focused_widget->can('is_focused') && $focused_widget->is_focused() ) {
        return $focused_widget;
    }
    return;
}


# <--------------- w1 ----------->
#  <-------------- w2 ---------->
#            <---- w3 --->
#              <-- w4 ->
# |----------[ the title ]-------|
#            w5         w6
#             |--- + ---|
#                  = w7
# --- o1 ----^
#
#        the complete title   <- the original title
#        -- o2 ->lete title   <- the displayed title
#
# in case of left position :
# |--------[ the title ]------------|
#  -- o3 --^
#
# in case of right position :
# |--------[ the title ]--------|
#                      ^-- o4 --

=head2 draw

Draw the widget. You shouldn't use that, the mainloop will take care of it. If
you are not using any mainloop, you should call draw() on the root window. See
Curses::Toolkit

=cut

sub draw {
    my ($self) = @_;
    $self->SUPER::draw();

    $self->get_theme_property('border_width') > 0 or return;

    my ( $c, $w1, $w2, $w3, $w4, $w5, $w6, $w7, $o3, $o4 ) = $self->_compute_draw_informations();

    my $title                     = $self->get_title();
    my @title_brackets_characters = @{ $self->get_theme_property('title_brackets_characters') };
    my $title_position            = $self->get_theme_property('title_position');


    if ( $w4 < length $title && $self->{_title_animation_direction} eq '' ) {

        # no animation were in place, we put one
        $self->{_title_animation_direction} = 'right';
        $self->{_title_offset}              = 0;
        $self->_start_animation();
    }

    my $o2 = $self->{_title_offset};

    my $title_to_display = '';
    $o2 < length $title
        and $title_to_display = substr( $title, $o2, $w4 );


    my $o1 = 0;
    if ( $title_position eq 'center' ) {
        $o1 = ( $w1 - $w3 ) / 2;
    } elsif ( $title_position eq 'left' ) {
        $o1 = 1 + $o3;                  # TODO : needs to change that with variable border width
        $o1 = min( $o1, $w1 - $w3 - 1 ) # TODO : needs to change that with variable border width
    } else {                            # right
        $o1 = $w1 - $w3 - 1 - $o4;      # TODO : needs to change that with variable border width
        $o1 = max( $o1, 1 );            # TODO : needs to change that with variable border width
    }

    my $theme = $self->get_theme();
    if ( length $title_to_display ) {
        $theme->draw_title(
            $c->get_x1() + $o1, $c->get_y1(),
            join( $title_to_display, @title_brackets_characters ),
            { clicked => $self->{_move_pressed} }
        );
    }

    #	$theme->draw_corner_lr($c->get_x2() - 1, $c->get_y2() - 1);
    $theme->draw_resize( $c->get_x2() - 1, $c->get_y2() - 1, { clicked => $self->{_resize_pressed} } );
}

=head2 get_visible_shape

Gets the Coordinates of the part of the window which is visible

  input  : none
  output : the shape (Curses::Toolkit::Object::Coordinates)

=cut

sub get_visible_shape {
    my ($self)      = @_;
    my $shape       = $self->get_coordinates->clone;
    my $root_window = $self->get_root_window
        or return $shape;
    my $root_shape = $root_window->get_shape;
    $shape->restrict_to($root_shape);
    return $shape;
}

sub _compute_draw_informations {
    my ($self) = @_;

    my $title_width               = $self->get_theme_property('title_width');
    my $c                         = $self->get_coordinates();
    my $title                     = $self->get_title();
    my @title_brackets_characters = @{ $self->get_theme_property('title_brackets_characters') };

    my $o3 = $self->get_theme_property('title_left_offset');
    my $o4 = $self->get_theme_property('title_right_offset');

    my $w1 = $c->width();
    my $w2 = $w1 - 2;    # TODO : needs to change that with variable border width
    my ( $w5, $w6 ) = map { length } @title_brackets_characters;
    my $w7 = $w5 + $w6;
    my $w3 = min( length($title) + $w7, $w2 * $title_width / 100 );
    my $w4 = $w3 - $w7;

    return ( $c, $w1, $w2, $w3, $w4, $w5, $w6, $w7, $o3, $o4 );
}

sub _start_animation {
    my ($self) = @_;
    my $root_window = $self->get_root_window();

    my $delay_sub;
    $delay_sub = sub {
        my ( $c, $w1, $w2, $w3, $w4, $w5, $w6, $w7, $o3, $o4 ) = $self->_compute_draw_informations();
        my $title = $self->get_title();

        if ( $w4 >= length $title ) {

            # stop the animation
            $self->{_title_offset}              = 0;
            $self->{_title_animation_direction} = '';
            return;
        }

        # continue the animation
        my $total_second = $self->get_theme_property('title_loop_duration') / 2; # TODO : reimplement
        my $nb_step      = length($title) - $w4 + 1;
        my $delay        = $total_second / $nb_step;
        if ( $self->{_title_animation_direction} eq 'right' ) {

            # animation goes to the right
            $self->{_title_offset}++;
        } else {

            # animation goes to the left
            $self->{_title_offset}--;
        }

        # 		# now check the boundaries
        if ( $self->{_title_offset} < 0 ) {
            $self->{_title_animation_direction} = 'right';
            $self->{_title_offset}              = 0;
            $delay                              = $self->get_theme_property('title_loop_pause');
        }
        if ( $self->{_title_offset} > length($title) - $w4 + 1 ) {
            $self->{_title_offset}              = length($title) - $w4 + 1;
            $self->{_title_animation_direction} = 'left';
            $delay                              = $self->get_theme_property('title_loop_pause');
        }
        $self->needs_redraw();
        my $root_window = $self->get_root_window();

        #		$delay = 1/4;
        $root_window->add_delay( $delay, $delay_sub );
    };

    # launch the animation in 1 second
    $root_window->add_delay( 1, $delay_sub );
    return;
}

=head2 set_type

Set the type of the window. Default is 'normal'.
Can be : 

  input  : SCALAR : the type, one of 'normal', 'menu'
  output : the window widget

=cut

my @possible_types = qw( normal menu );

sub set_type {
    my $self = shift;
    my ($type) = validate_pos(
        @_,
        {   type      => SCALAR,
            callbacks => {
                "one of @possible_types" => sub {
                    my ($arg) = @_;
                    any { $arg eq $_ } @possible_types;
                    }
            }
        }
    );

    $self->{type} = $type;
    return $self;
}

=head2 get_type

Get the type of the window

  input : none
  output : the type

=cut

sub get_type {
    my ($self) = @_;
    return $self->{type};
}

=head1 Theme related properties

To set/get a theme properties, you should do :

  $window->set_theme_property(property_name => $property_value);
  $value = $window->get_theme_property('property_name');

Here is the list of properties related to the window, that can be changed in
the associated theme. See the Curses::Toolkit::Theme class used for the default
(default class to look at is Curses::Toolkit::Theme::Default)

Don't forget to look at properties from the parent class, as these are also
inherited from !

=head2 border_width (inherited)

The width of the border of the window.

Example :
  # set window to have no border
  $button->set_theme_property(border_width => 0 );

=head2 title_width

The width (or the height if the title is displayed vertically) of the window
that will be use to display the title, in percent.

Example :
  # the title can take up to 80% of the windows border
  $window->set_theme_property(title_width => 80 );

=head2 title_bar_position

Can be 'top', 'bottom', 'left', 'right', sets the position of the title bar on the window border
Example :
  # The title will appear on the left
  $window->set_theme_property(title_position => 'left');

=head2 title_position

Specifies if the title should be on the left/top, center or right/bottom on the title bar. Can be 'left', 'center' or 'right'

=head2 title_brackets_characters

An ARRAYREF of 2 strings (usually 1 character long), the first one is displayed
before the title, the second one is used after the title.

Example :
  # The title will appear <like that>
  $window->set_theme_property(title_brackets_characters => [ '<', '>' ]);

=head2 title_left_offset

If title_position is 'left', this offset will be used to move the title on the right

=head2 title_right_offset

If title_position is 'right', this offset will be used to move the title on the left

=head2 title_animation

If set to 1, when the title is too big to be displayed in the window title bar,
an animation will make the title loop back and forth.

=head2 title_loop_duration

If the title is too big to be displayed in the window title bar, an animation
will make the title loop back and forth. This properties let's you specify what
should be the complete animation duration. It's in seconds, but fractions are
accepted

=head2 title_loop_pause

This sets the duration the loop animation should pause before going to the
other direction. It's in seconds, but fractions are accepted

=cut

my @title_bar_positions = qw(top bottom left right);
my @title_positions     = qw(left center right);

sub _get_theme_properties_definition {
    my ($self) = @_;
    return {
        %{ $self->SUPER::_get_theme_properties_definition() },
        title_width => {
            optional  => 1,
            callbacks => {
                "should be between 0 and 100 (percent)" => sub {
                    $_[0] <= 100 && $_[0] >= 0;
                    }
            }
        },
        title_bar_position => {
            optional  => 1,
            callbacks => {
                "should be one of @title_bar_positions" => sub {
                    my ($arg) = @_;
                    any { $arg eq $_ } @title_bar_positions;
                    }
            }
        },
        title_position => {
            optional  => 1,
            callbacks => {
                "should be one of @title_positions" => sub {
                    my ($arg) = @_;
                    any { $arg eq $_ } @title_positions;
                    }
            }
        },
        title_brackets_characters => {
            optional  => 1,
            type      => ARRAYREF,
            callbacks => {
                "should contain 2 strings" => sub {
                    @{ $_[0] } == 2 && none { ref } @{ $_[0] };
                    }
            }
        },
        title_left_offset => {
            optional  => 1,
            type      => SCALAR,
            callbacks => {
                "positive integer" => sub {
                    $_[0] >= 0;
                    }
            }
        },
        title_right_offset => {
            optional  => 1,
            type      => SCALAR,
            callbacks => {
                "positive integer" => sub {
                    $_[0] >= 0;
                    }
            }
        },
        title_animation => {
            optional  => 1,
            type      => BOOLEAN,
            callbacks => {
                "1 or 0" => sub {
                    $_[0] =~ /^1|0$/;
                    }
            },
        },
        title_loop_duration => {
            optional  => 1,
            type      => SCALAR,
            callbacks => {
                "strictly positive float (seconds)" => sub {
                    $_[0] > 0;
                    }
            }
        },
        title_loop_pause => {
            optional  => 1,
            type      => SCALAR,
            callbacks => {
                "positive float (seconds)" => sub {
                    $_[0] >= 0;
                    }
            }
        },
    };
}

1;
