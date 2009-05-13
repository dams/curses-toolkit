package Curses::Toolkit::Widget::Window;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Bin);

=head1 NAME

Curses::Toolkit::Widget::Window - a window

=head1 DESCRIPTION

This is a window widget

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Window

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	# set window stack by default
	$self->set_property('window', 'stack', -1);
	return $self;
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
	if ( ! ref($_[0])) {
		print STDERR Dumper(\@_);
		my %params = @_;
		foreach my $x (qw(x1 x2)) {
			if ($params{$x} =~ /^(.+)%$/ ) {
				my $percent = $1;
				$params{$x} = sub { return $self->get_root_window()
									  ? $self->get_root_window()->get_shape()->width() * $percent / 100
									  : 0;
								   };
			}
		}
		foreach my $y (qw(y1 y2)) {
			if ($params{$y} =~ /^(.+)%$/ ) {
				my $percent = $1;
				$params{$y} = sub { return $self->get_root_window()
									  ? $self->get_root_window()->get_shape()->height() * $percent / 100
								      : 0;
								  };
			}
		}
		if (defined $params{width} && $params{width} =~ /^(.+)%$/ ) {
			my $percent = $1;
			$params{x2} = sub {
				my ($coord) = @_;
				$coord->x1() + ($self->get_root_window() and $self->get_root_window()->get_shape()->width() * $percent / 100);
			};
			delete $params{width};
		}
		if (defined $params{height} && $params{height} =~ /^(.+)%$/ ) {
			my $percent = $1;
			$params{y2} = sub {
				my ($coord) = @_;
				$coord->y1() + ($self->get_root_window() and $self->get_root_window()->get_shape()->height() * $percent / 100);
			};
			delete $params{height};
		}
		$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(%params);
	} else {
		$self->{coordinates} = Curses::Toolkit::Object::Coordinates->new(@_);
	}
	$self->_set_relatives_coordinates($self->{coordinates});
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
	my ($self, $root_window) = @_;
	print STDERR "-_-_--_-_--_-_--_-_--_-_- RC 55 1 : $root_window \n";

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
	print STDERR "-_-_--_-_--_-_--_-_--_-_- RC 55 2 : " . $self->{root_window} . "\n";
	return $self->{root_window};
}

1;
