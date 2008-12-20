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

  input : clear_background : optional, boolean, default 1 : if true, clears background
  output : a Curses::Toolkit object

=cut

sub init_root_window {
    my $class = shift;
    
    my %params = validate(@_, { clear => { type => BOOLEAN,
										   default => 1,
										 },
								theme => { isa => 'Curses::Toolkit::Theme',
										   optional => 1,
										 },
							  }
                         );

    # get the Curses handler
    use Curses;
    my $curses_handler = Curses->new();
    
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
	$params{theme} ||= Curses::Toolkit::Theme::Default->new();
    my $self = bless { initialized => 1, 
                       curses_handler => $curses_handler,
                       windows => [],
                     }, $class;
    return $self;
}

DESTROY {
    my ($obj) = @_;
    # ending Curses
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

Draw everything on the screen

  input : none
  output : the root window

=cut

sub render {
    my ($self) = @_;
	foreach my $window (sort { $b->{stack} <=> $a->{stack} } $self->get_windows()) {
		$window->render($self->{curses_handler});
	}
	return $self;
}

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
