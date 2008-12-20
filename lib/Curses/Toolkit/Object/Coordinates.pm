package Curses::Toolkit::Object::Coordinates;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Object);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Object::Coordinates - simple coordinates class

=head1 DESCRIPTION

Trivial class to hold 2 points

=head1 CONSTRUCTOR

=head2 new

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
  output : the coordinates object

=cut

sub new {
	my $class = shift;
	my %params = validate(@_, { x1 => { type => SCALAR }, x2 => { type => SCALAR },
							    y1 => { type => SCALAR }, y2 => { type => SCALAR },
							  }
						 );
	$params{x1} < $params{x2} or ($params{x1}, $params{x2}) = ($params{x2}, $params{x1});
	$params{y1} < $params{y2} or ($params{y1}, $params{y2}) = ($params{y2}, $params{y1});
	my $self = bless \%params, $class;
	return $self; 
}

=head2 width

returns the width represented by the coordinates

=cut

sub width {
	my ($self) = @_;
	return $self->{x2} - $self->{x1};
}

=head2 height

returns the height represented by the coordinates

=cut

sub height {
	my ($self) = @_;
	return $self->{y2} - $self->{y1};
}

=head2 x1, x2, y1, y2

These are helpers to retrieve the coordinates values

=cut

sub x1 { shift->{x1} }
sub y1 { shift->{y1} }
sub x2 { shift->{x2} }
sub y2 { shift->{y2} }

1;
