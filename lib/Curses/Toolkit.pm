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

=head1 SYNOPSIS

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
		print STDERR "color is supported\n";
		print STDERR "colors number : " . COLORS . "\n";
		print STDERR "colors pairs : " . COLOR_PAIRS . "\n";
		print STDERR "can change colors ? : " . Curses::can_change_color() . "\n";

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
                     }, $class;
    return $self;
}

=head2 set_mainloop

  my $root->set_mainloop($mainloop)

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


DESTROY {
    my ($obj) = @_;
    # ending Curses
    ref($obj) eq 'Curses::Toolkit' and
	  Curses::endwin;
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
    push @{$self->{windows}}, $window;
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
	my ($screen_h, $screen_w);
	$self->{curses_handler}->getmaxyx($screen_h, $screen_w);
#	$self->{curses_handler}->erase();
	foreach my $window (sort { $b->get_property('window', 'stack') <=> $a->get_property('window', 'stack') } $self->get_windows()) {
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

#    my ($screen_w, $screen_h);
#    $self->{curses_handler}->getmaxyx($screen_h, $screen_w);
#    return $self->render_rectangle(0, 0, $screen_h, $screen_w);

# =head2 render

#   $root->render(10, 10, 50, 20);

# Draw only a rectangle

#   input : position1 x
#           position1 y
#           position2 x
#           position2 y
#   output : the root window

# =cut

# sub render_rectangle {
#     my $self = shift;
#     my ($pos1x, $pos1y, $pos2x, $pos2y) =
#       validate_pos( @_, { type => SCALAR,}, { type => SCALAR },
#                         { type => SCALAR }, { type => SCALAR },
#                   );
#     $pos1x <= $pos2x or ($pos1x, $pos2x) = ($pos2x, $pos1x);
#     $pos1y <= $pos2y or ($pos1y, $pos2y) = ($pos2y, $pos1y);
#     foreach my $window ($self->get_windows()) {
#         if ($window->is_in_rectangle($pos1x, $pos1y, $pos2x, $pos2y)) {
#             $window->draw_rectangle($pos1x, $pos1y, $pos2x, $pos2y);
#         }
#     }
# }


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
