package Curses::Toolkit;

use warnings;
use strict;

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit - a modern Curses toolkit

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This module tries to be a modern curses toolkit, based on the Curses module, to
build "graphical" console user interfaces easily.

However, please consider using L<POE::Component::Curses>, which is probably
what you want. L<POE::Component::Curses> uses Curses::Toolkit, but provides a
mainloop and handles keyboard, mouse, timer and other events, whereas
Curses::Toolkit is just the drawing library.

However if you already have a mainloop or if you don't need it, you might want
to use Curses::Toolkit directly. But again, it's probably not what you want to
use.

  use Curses::Toolkit;

  my $root = Curses::Toolkit->init_root_window();
  my $window = Curses::Toolkit::Widget::Window->new();
  $root->add($window);
  ...
  $root->render

=head1 CLASS METHODS

=head2 init_root_window

  my $root = Curses::Toolkit->init_root_window();

Initialize the Curses environment, and return an object representing it. This
is not really a constructor, because you can't have more than one
Curses::Toolkit object for one Curses environment.

  input  : clear_background  : optional, boolean, default 1 : if true, clears background
           theme_name        : optional, the name of them to use as default diosplay theme
           mainloop          : optional, the mainloop object that will be used for event handling
  output : a Curses::Toolkit object

=cut

sub init_root_window {
    my $class = shift;
    
    my %params = validate(@_, { clear => { type => BOOLEAN,
										   default => 1,
										 },
								theme_name => { type => SCALAR,
												optional => 1,
											   },
								mainloop => { optional => 1
												},
							  }
                         );

    # get the Curses handler
    use Curses;
    my $curses_handler = Curses->new();
	if (has_colors) {
		start_color();
# 		print STDERR "color is supported\n";
# 		print STDERR "colors number : " . COLORS . "\n";
# 		print STDERR "colors pairs : " . COLOR_PAIRS . "\n";
# 		print STDERR "can change colors ? : " . Curses::can_change_color() . "\n";

#  	my $pair_nb = 1;
#  	foreach my $bg_nb (0..COLORS()-1) {
#  		foreach my $fg_nb (0..COLORS()-1) {
#  #			print STDERR "color pairing : $pair_nb, $fg_nb, $bg_nb \n";
#  			init_pair($pair_nb, $fg_nb, $bg_nb);
#  			$pair_nb++;
#  		}
#  	}

# 	my $curses = $curses_handler;
# 	foreach my $x (0..7) {
# 		$curses->addstr(0, ($x+1)*3, $x);
# 	}
# 	foreach my $y (0..7) {
# 		$curses->addstr($y+1, 0, $y);
# 	}

# 	my $pair = 1;
# 	foreach my $x (0..7) {
# 		foreach my $y (0..7) {
# 			COLOR_PAIR($pair);
# 			$curses->attrset(COLOR_PAIR($pair));
# 			$curses->addstr($y+1, ($x+1)*3, "$x$y");
# 			$pair++;
# 		}
# 	}

	} else {
		print STDERR "no color support\n";
	}

    eval { Curses->can('NCURSES_MOUSE_VERSION') && (NCURSES_MOUSE_VERSION() >= 1 ) };

	my $old_mouse_mask;
	my $mouse_mask = mousemask(ALL_MOUSE_EVENTS, $old_mouse_mask); 


    # curses basic init
#    Curses::noecho();
#    Curses::cbreak();
#    curs_set(0);
#    Curses::leaveok(1);

#$curses_handler->erase();

    # erase the window if asked.
#    print STDERR Dumper($params{clear}); use Data::Dumper;
#    $params{clear} and $curses_handler->erase();
    
#    use Curses::Toolkit::Widget::Container;
#    my $container = Curses::Toolkit::Widget::Warper->new();

	use Curses::Toolkit::Theme::Default;
	use Curses::Toolkit::Theme::Default::Color;
	$params{theme_name} ||= (has_colors() ? 'Curses::Toolkit::Theme::Default::Color' : 'Curses::Toolkit::Theme::Default');
    my $self = bless { initialized => 1, 
                       curses_handler => $curses_handler,
                       windows => [],
					   theme_name => $params{theme_name},
					   mainloop => $params{mainloop},
					   last_stack => 0,
					   event_listeners => [],
                     }, $class;
	$self->_recompute_shape();

	use Curses::Toolkit::EventListener;
	# add a default listener that listen to any Shape event
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Shape',
			conditional_code => sub { 1; },
			code => sub {
				my ($screen_h, $screen_w);
				$self->_recompute_shape();
				# for now we rebuild all coordinates
				foreach my $window ( $self->get_windows() ) {
					$window->rebuild_all_coordinates();
				}
			},
		)
	);
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Key',
			conditional_code => sub { 
				my ($event) = @_;
				$event->{type} eq 'stroke' or return 0;
				lc $event->{params}{key} eq 'q' or return 0;
			},
			code => sub {
				print STDERR "received Q, bailing out\n";
				exit;
			},
		)
	);
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Key',
			conditional_code => sub { 
				my ($event) = @_;
				$event->{type} eq 'stroke' or return 0;
				$event->{params}{key} eq '<^I>' or return 0;
			},
			code => sub {
				my $focused_widget = $self->get_focused_widget();
				if (defined $focused_widget) {
					my $next_focused_widget = $focused_widget->get_next_focused_widget();
					defined $next_focused_widget and 
					  $next_focused_widget->set_focus(1);
				}
			},
		)
	);
    return $self;
}

# destroyer
DESTROY {
    my ($obj) = @_;
    # ending Curses
    ref($obj) eq 'Curses::Toolkit' and
	  Curses::endwin;
}


=head1 METHODS

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
	push @{$self->{event_listeners}}, $listener;
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
	return @{$self->{event_listeners}};
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
	my $window = (sort { $b->get_property(window => 'stack') <=> $a->get_property(window => 'stack') } @windows)[0];
	return $window;
}

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
	$window->_set_curses_handler($self->{curses_handler});
	$window->set_theme_name($self->{theme_name});
	$window->set_root_window($self);
	$self->{last_stack} = $self->{last_stack} + 1;
	$window->set_property(window => 'stack', $self->{last_stack});
	# in case the window has proportional coordinates depending on the root window
	# TODO : do that only if window has proportional coordinates, not always
	$window->rebuild_all_coordinates();
    push @{$self->{windows}}, $window;
	$self->needs_redraw();
	return $self;
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
    return @{$self->{windows}};
}


=head2 show_all

  $root->show_all();

Set visibility property to true for every element. Returns the root windows

  input : none
  output : the root window

=cut

sub show_all {
    my ($self) = @_;
    foreach my $window ($self->get_windows()) {
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
	$self->{curses_handler}->erase();
	foreach my $window (sort { $a->get_property(window => 'stack') <=> $b->get_property(window => 'stack') } $self->get_windows()) {
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

Given an event, dispatch it to the appropriate widgets / windows, or to the root window.

  input  : a Curses::Toolkit::Event
  output : true if the event were handled, false if not

=cut

sub dispatch_event {
	my $self = shift;
	my ($event) = validate_pos(@_, { isa => 'Curses::Toolkit::Event' });

	my $widget = $event->get_matching_widget();

	while ( 1 ) {
		foreach my $listener ($widget->get_event_listeners()) {
			if ($listener->can_handle($event)) {
				return $listener->send_event($event);
			}
		}
		if ($widget->isa('Curses::Toolkit::Widget::Window')) {
			$widget = $widget->get_root_window();
		} elsif ($widget->isa('Curses::Toolkit::Widget')) {
			$widget = $widget->get_parent();
		} else {
			return;
		}
		defined $widget or return;
	}
	return;
}


# ## Private methods ##

# # event_handling

# my @supported_events = (qw(Curses::Toolkit::Event::Shape));
# sub _handle_event {
# 	my ($self, $event) = @_;
# 	use List::MoreUtils qw(any);
# 	if ( any { $event->isa($_) } @supported_events ) {
# 		my $method_name = '_event_' . lc( (split('::|_', ref($event)))[-1] ) . '_' .  $event->get_type();
# 		if ($self->can($method_name)) {
# 			return $self->$method_name();
# 		}
# 	}
# 	# event failed being applied
# 	return 0;
# }

# core event handling for Curses::Toolkit::Event::Shape event of type 'change'
sub _event_shape_change {
	my ($self) = @_;

	my ($screen_h, $screen_w);
	$self->_recompute_shape();

# for now we rebuild all coordinates
 	foreach my $window ( $self->get_windows() ) {
		$window->rebuild_all_coordinates();
 	}

# for now rebuild everything
#	my $mainloop = $self->get_mainloop();
#	if (defined $mainloop) {
#		$mainloop->needs_redraw();
#	}

	# event suceeded
	return 1;

}

sub _recompute_shape {
	my ($self) = @_;
	use Curses::Toolkit::Object::Coordinates;
	my ($screen_h, $screen_w);
    use Curses;
	endwin;
	$self->{curses_handler}->getmaxyx($screen_h, $screen_w);
	use Curses::Toolkit::Object::Shape;
	$self->{shape} ||= Curses::Toolkit::Object::Shape->new_zero();
	$self->{shape}->_set(
		x2 => $screen_w,
		y2 => $screen_h,
	);
	return $self;
}

=head1 AUTHOR

Damien "dams" Krotkine, C<< <dams at cpan.org> >>

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

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Damien "dams" Krotkine, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Curses::Toolkit
