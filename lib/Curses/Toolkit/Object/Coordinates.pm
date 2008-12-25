package Curses::Toolkit::Object::Coordinates;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Object);

use Params::Validate qw(:all);

use overload
  '+' => 'add',
  '-' => 'substract';

sub add {
	my ($self, $c) = @_;
	return __PACKAGE__->new( x1 => $self->x1() + $c->x1(), y1 => $self->y1() + $c->y1(),
							 x2 => $self->x2() + $c->x2(), y2 => $self->y2() + $c->y2(),
						   );
}

sub substract {
	my ($self, $c) = @_;
	# argument is a constant
	ref $c or
	  return __PACKAGE__->new( x1 => $self->x1() - $c, y1 => $self->y1() - $c,
							   x2 => $self->x2() - $c, y2 => $self->y2() - $c,
							 );
	# argument is a Coordinates object
	if ($c->isa(__PACKAGE__)) {
		return __PACKAGE__->new( x1 => $self->x1() - $c->x1(), y1 => $self->y1() - $c->y1(),
								 x2 => $self->x2() - $c->x2(), y2 => $self->y2() - $c->y2(),
							   );
	}
	die "Argument type ('" . ref $c . "') is not supported in Coordinate substraction";
}


=head1 NAME

Curses::Toolkit::Object::Coordinates - simple coordinates class

=head1 DESCRIPTION

Trivial class to hold 2 points

+ and - are properly overloaded

=head1 CONSTRUCTOR

=head2 new

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
    OR
  input  : x1 : top left x
           y1 : top left y
           width : width
           height : heigth
    OR
  input  : a Curses::Toolkit::Object::Coordinates object

  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub new {
	my $class = shift;

	if (ref($_[0]) eq __PACKAGE__) {
		my $c = $_[0];
		my $self = { x1 => $c->x1(), y1 => $c->y1(),
					 x2 => $c->x2(), y2 => $c->y2(),
				   };
		return bless $self, $class;
	}
	my %params = @_;
	if (exists $params{width} || exists $params{height}) {
		validate(@_, { x1 => { type => SCALAR }, y1 => { type => SCALAR },
					   width => { type => SCALAR }, height => { type => SCALAR },
					 }
				);
		$params{x2} = $params{x1} + $params{width};
		$params{y2} = $params{y1} + $params{height};
	} else {
		validate(@_, { x1 => { type => SCALAR }, y1 => { type => SCALAR },
					   x2 => { type => SCALAR }, y2 => { type => SCALAR },
					 }
				);
	}
	$params{x1} < $params{x2} or ($params{x1}, $params{x2}) = ($params{x2}, $params{x1});
	$params{y1} < $params{y2} or ($params{y1}, $params{y2}) = ($params{y2}, $params{y1});
	my $self = bless \%params, $class;
	return $self; 
}

=head2 new_zero

Creates a new coordinates with all zero

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub new_zero {
	my ($class) = @_;
	return $class->new( x1 => 0, y1 => 0,
						x2 => 0, y2 => 0 );
}

=head1 METHODS

=head2 clone

clone an coordinates object

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub clone {
	my ($self) = @_;
	return ref($self)->new($self);
}

=head2 set

set attributes of the coordinate

  input  : one or more of x1, x2, y1, y2, width, height
  output : the coordinate object

=cut

sub set {
	my $self = shift;
	my %params = validate(@_, { x1 => { type => SCALAR, optional => 1 }, y1 => { type => SCALAR, optional => 1 },
								x2 => { type => SCALAR, optional => 1 }, y2 => { type => SCALAR, optional => 1 },
							  });
	keys %params or die "One of (x1, y1, x2, y2) argument must be passed";
	@{$self}{keys %params} = values %params;
	return $self;
}

=head2 width

returns the width represented by the coordinates

=cut

sub width {
	my ($self) = @_;
	return $self->{x2} - $self->{x1} + 1;
}

=head2 height

returns the height represented by the coordinates

=cut

sub height {
	my ($self) = @_;
	return $self->{y2} - $self->{y1} + 1;
}

=head2 x1, x2, y1, y2

These are helpers to retrieve the coordinates values

=cut

sub x1 { shift->{x1} }
sub y1 { shift->{y1} }
sub x2 { shift->{x2} }
sub y2 { shift->{y2} }

1;
