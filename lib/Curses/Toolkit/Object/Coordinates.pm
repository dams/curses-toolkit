use warnings;
use strict;

package Curses::Toolkit::Object::Coordinates;

# ABSTRACT: simple coordinates class

use parent qw(Curses::Toolkit::Object);

use Params::Validate qw(:all);

use overload
    '+'  => '_clone_add',
    '-'  => '_clone_subtract',
    '""' => '_stringify',
    '==' => '_equals';

sub _stringify {
    my ($self) = @_;
    return $self->width . 'x' . $self->height . '+' . $self->get_x1 . 'x' . $self->get_y1;
}

sub _equals {
    my ( $c1, $c2 ) = @_;
    return
           $c1->get_x1() == $c2->get_x1()
        && $c1->get_y1() == $c2->get_y1()
        && $c1->get_x2() == $c2->get_x2()
        && $c1->get_y2() == $c2->get_y2();
}

=head1 DESCRIPTION

Trivial class to hold 2 points

+ and - are properly overloaded

=head1 CONSTRUCTOR

=head2 new

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
           [ normalize ] : optional, if false, won't normalize the coords (see below)
    OR
  input  : x1 : top left x
           y1 : top left y
           width : width
           height : heigth
           [ normalize ] : optional, if false, won't normalize the coords (see below)
    OR
  input  : x1 : sub { ... } # returns top left x
           y1 : sub { ... } # returns top left y
           x2 : sub { ... } # returns right bottom x
           y2 : sub { ... } # returns right bottom y
           [ normalize ] : optional, if false, won't normalize the coords (see below)
    OR
  input  : a Curses::Toolkit::Object::Coordinates object

  output : a Curses::Toolkit::Object::Coordinates object


Normalize option : if set to false, the coordinate will be untouched. If set to
true (default), the coordinate will make sure x1 < x2 and y1 < y2, and that
they are all integers, swapping or rounding them if necessary.

=cut

sub new {
    my $class = shift;

    if ( ref( $_[0] ) eq __PACKAGE__ ) {
        my $c    = $_[0];
        my $self = {
            x1 => $c->{x1}, y1 => $c->{y1},
            x2 => $c->{x2}, y2 => $c->{y2},
        };
        return bless $self, $class;
    }
    my %params = @_;
    if ( exists $params{width} || exists $params{height} ) {
        validate(
            @_,
            {   x1        => { type     => SCALAR }, y1     => { type => SCALAR },
                width     => { type     => SCALAR }, height => { type => SCALAR },
                normalize => { optional => 1,        type   => BOOLEAN },
            }
        );
        $params{x2} = $params{x1} + $params{width};
        $params{y2} = $params{y1} + $params{height};
        defined $params{normalize} or $params{normalize} = 1;
    } else {
        validate(
            @_,
            {   x1        => { type     => SCALAR | CODEREF }, y1   => { type => SCALAR | CODEREF },
                x2        => { type     => SCALAR | CODEREF }, y2   => { type => SCALAR | CODEREF },
                normalize => { optional => 1,                  type => BOOLEAN },
            }
        );
    }
    my $self = bless \%params, $class;
    $params{normalize} and $self->_normalize();
    return $self;
}

=head2 new_zero

Creates a new coordinates with all zero

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub new_zero {
    my ($class) = @_;
    return $class->new(
        x1 => 0, y1 => 0,
        x2 => 0, y2 => 0
    );
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
    my $self   = shift;
    my %params = validate(
        @_,
        {   x1 => { type => SCALAR | CODEREF, optional => 1 }, y1 => { type => SCALAR | CODEREF, optional => 1 },
            x2 => { type => SCALAR | CODEREF, optional => 1 }, y2 => { type => SCALAR | CODEREF, optional => 1 },
        }
    );
    keys %params or die "One of (x1, y1, x2, y2) argument must be passed";
    @{$self}{ keys %params } = values %params;
    $self->_normalize();
    return $self;
}

# make sure the coordinate is positive
sub _normalize {
    my ($self) = @_;

    $self->get_x1() <= $self->get_x2() or ( $self->{x1}, $self->{x2} ) = ( $self->{x2}, $self->{x1} );
    $self->get_y1() <= $self->get_y2() or ( $self->{y1}, $self->{y2} ) = ( $self->{y2}, $self->{y1} );
    return;
}

=head2 width

returns the width represented by the coordinates

=cut

sub width {
    my ($self) = @_;
    return $self->get_x2() - $self->get_x1();
}

=head2 height

returns the height represented by the coordinates

=cut

sub height {
    my ($self) = @_;
    return $self->get_y2() - $self->get_y1();
}

=head2 x1, x2, y1, y2

These are helpers to retrieve the coordinates values

=cut

sub get_x1 { my ($self) = @_; my $x1 = $self->{x1}; ref $x1 eq 'CODE' ? $x1->($self) : $x1 }
sub get_y1 { my ($self) = @_; my $y1 = $self->{y1}; ref $y1 eq 'CODE' ? $y1->($self) : $y1 }
sub get_x2 { my ($self) = @_; my $x2 = $self->{x2}; ref $x2 eq 'CODE' ? $x2->($self) : $x2 }
sub get_y2 { my ($self) = @_; my $y2 = $self->{y2}; ref $y2 eq 'CODE' ? $y2->($self) : $y2 }


=head2 add

Add to the coordinate.

If the argument is a constant, it's added to all the components of the
coordinate.
If it's a Curses::Toolkit::Object::Coordinates, it's added side by side
If it's a hashref, it's added side by side

  input  : a CONSTANT
OR
  input  : a Curses::Toolkit::Object::Coordinates
OR
  input  : a HASHREF of 'x1', 'x2', 'y1', 'y2'

output : the Curses::Toolkit::Object::Coordinates object

=cut

sub add {
    my ( $self, $c ) = @_;

    if ( !ref $c ) {

        # argument is a constant
        @{$self}{qw(x1 y1 x2 y2)} = (
            $self->get_x1() + $c, $self->get_y1() + $c,
            $self->get_x2() + $c, $self->get_y2() + $c,
        );
    } elsif ( ref $c eq __PACKAGE__ ) {

        # argument is a coordinate object
        @{$self}{qw(x1 x2 y1 y2)} = (
            $self->get_x1() + $c->get_x1(), $self->get_x2() + $c->get_x2(),
            $self->get_y1() + $c->get_y1(), $self->get_y2() + $c->get_y2(),
        );
    } elsif ( ref $c eq 'HASH' ) {

        # argument is a hash
        while ( my ( $k, $v ) = each %$c ) {
            my $meth = "get_$k";
            $self->{$k} = $self->$meth + $v;
        }
    } else {
        die "Argument type ('" . ref($c) . "') is not supported in Coordinate addition";
    }
    $self->_normalize();
    return $self;
}

sub _clone_add {
    my $self  = shift;
    my $clone = $self->clone();
    $clone->add(@_);
    return $clone;
}

# sub add {
# 	my ($self, $c) = @_;
# 	# argument is a constant
# 	ref $c or
# 	  return $self->set( x1 => $self->get_x1() + $c, y1 => $self->get_y1() + $c,
# 							   x2 => $self->get_x2() + $c, y2 => $self->get_y2() + $c,
# 							 );

# 	# argument is a coordinate object
# 	ref $c eq $self and
# 	  return $self->set( x1 => $self->get_x1() + $c->get_x1(), y1 => $self->get_y1() + $c->get_y1(),
# 							   x2 => $self->get_x2() + $c->get_x2(), y2 => $self->get_y2() + $c->get_y2(),
# 							 );
# 	# argument is a hash
# 	ref $c eq 'HASH' and
# 	  return $self->set( x1 => $self->get_x1() + $c->{x1}, y1 => $self->get_y1() + $c->{y1},
# 							   x2 => $self->get_x2() + $c->{x2}, y2 => $self->get_y2() + $c->{y2},
# 							 );

# 	die "Argument type ('" . ref $c . "') is not supported in Coordinate addition";
# }

=head2 subtract

Substract from the coordinate (also overloads '-').

If the argument is a constant, it's subtracted from all the components of the
coordinate.
If it's a Curses::Toolkit::Object::Coordinates, it's subtracted side by side
If it's a hashref, it's subtracted side by side

  input  : a CONSTANT
OR
  input  : a Curses::Toolkit::Object::Coordinates
OR
  input  : a HASHREF of 'x1', 'x2', 'y1', 'y2'

output : the Curses::Toolkit::Object::Coordinates object

=cut

sub subtract {
    my ( $self, $c ) = @_;

    if ( !ref $c ) {

        # argument is a constant
        @{$self}{qw(x1 y1 x2 y2)} = (
            $self->get_x1() - $c, $self->get_y1() - $c,
            $self->get_x2() - $c, $self->get_y2() - $c,
        );
    } elsif ( ref $c eq __PACKAGE__ ) {

        # argument is a coordinate object
        @{$self}{qw(x1 x2 y1 y2)} = (
            $self->get_x1() - $c->get_x1(), $self->get_x2() - $c->get_x2(),
            $self->get_y1() - $c->get_y1(), $self->get_y2() - $c->get_y2(),
        );
    } elsif ( ref $c eq 'HASH' ) {

        # argument is a hash
        while ( my ( $k, $v ) = each %$c ) {
            my $meth = "get_$k";
            $self->{$k} = $self->$meth - $v;
        }
    } else {
        die "Argument type ('" . ref($c) . "') is not supported in Coordinate addition";
    }
    $self->_normalize();
    return $self;
}

sub _clone_subtract {
    my $self  = shift;
    my $clone = $self->clone();
    $clone->subtract(@_);
    return $clone;
}

# sub subtract {
# 	my ($self, $c) = @_;
# 	# argument is a constant
# 	ref $c or
# 	  return $self->set( x1 => $self->get_x1() - $c, y1 => $self->get_y1() - $c,
# 							   x2 => $self->get_x2() - $c, y2 => $self->get_y2() - $c,
# 							 );
# 	# argument is a Coordinates object
# 	if ($c->isa($self)) {
# 		return $self->set( x1 => $self->get_x1() - $c->get_x1(), y1 => $self->get_y1() - $c->get_y1(),
# 								 x2 => $self->get_x2() - $c->get_x2(), y2 => $self->get_y2() - $c->get_y2(),
# 							   );
# 	}
# 	# argument is a hash
# 	ref $c eq 'HASH' and
# 	  return $self->set( x1 => $self->get_x1() - $c->{x1}, y1 => $self->get_y1() - $c->{y1},
# 							   x2 => $self->get_x2() - $c->{x2}, y2 => $self->get_y2() - $c->{y2},
# 							 );
# 	die "Argument type ('" . ref $c . "') is not supported in Coordinate subtraction";
# }

=head2 restrict_to

Force the coordinate to be inside the passed coordinate.

  input  : a Curses::Toolkit::Object::Coordinates object
  output : the object

=cut

sub restrict_to {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );

    $self->get_x1() < $c->get_x1() and $self->{x1} = $c->{x1};
    $self->get_x1() > $c->get_x2() and $self->{x1} = $c->{x2};

    $self->get_x2() > $c->get_x2() and $self->{x2} = $c->{x2};
    $self->get_x2() < $c->get_x1() and $self->{x2} = $c->{x1};

    $self->get_y1() < $c->get_y1() and $self->{y1} = $c->{y1};
    $self->get_y1() > $c->get_y2() and $self->{y1} = $c->{y2};

    $self->get_y2() > $c->get_y2() and $self->{y2} = $c->{y2};
    $self->get_y2() < $c->get_y1() and $self->{y2} = $c->{y1};

    return $self;
}

=head2 grow_to

Force the coordinate to be at least as big as the passed coordinate.

  input  : a Curses::Toolkit::Object::Coordinates object
  output : the object

=cut

sub grow_to {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );

    $self->get_x1() > $c->get_x1() and $self->{x1} = $c->{x1};
    $self->get_x2() < $c->get_x2() and $self->{x2} = $c->{x2};

    $self->get_y1() > $c->get_y1() and $self->{y1} = $c->{y1};
    $self->get_y2() < $c->get_y2() and $self->{y2} = $c->{y2};

    return $self;
}

=head2 translate

Given a X value and a Y value, translates the coordinate accordingly

  input  : x : value to translate the coord horizontally
           y : value to translate the coord vertically
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate {
    my $self = shift;

    my %params = validate(
        @_,
        {   x => { type => SCALAR, optional => 1 },
            y => { type => SCALAR, optional => 1 },
        }
    );
    defined $params{x} || $params{y}
        or die "needs at least one of 'x' or 'y'";

    if ( defined $params{x} ) {
        $self->{x1} += $params{x};
        $self->{x2} += $params{x};
    }
    if ( defined $params{y} ) {
        $self->{y1} += $params{y};
        $self->{y2} += $params{y};
    }
    return $self;
}

=head2 translate_up

Given a value, translates the coordinate up (value sign is ignored)

  input  : value to translate the coord up
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_up {
    my ( $self, $value ) = @_;
    return $self->translate( y => -abs $value );
}

=head2 translate_down

Given a value, translates the coordinate down (value sign is ignored)

  input  : value to translate the coord down
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_down {
    my ( $self, $value ) = @_;
    return $self->translate( y => abs $value );
}

=head2 translate_left

Given a value, translates the coordinate left (value sign is ignored)

  input  : value to translate the coord left
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_left {
    my ( $self, $value ) = @_;
    return $self->translate( x => -abs $value );
}

=head2 translate_right

Given a value, translates the coordinate right (value sign is ignored)

  input  : value to translate the coord right
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_right {
    my ( $self, $value ) = @_;
    return $self->translate( x => abs $value );
}

=head2 contains

Return true if the coordinates contains the given coordinates

  my $boolean = $self->contains( $coord )

  input  : a Curses::Toolkit::Object::Coordinates object : the coordinates
  output : true or false

=cut

sub contains {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );
    return
           $self->get_x1() <= $c->get_x1()
        && $self->get_y1() <= $c->get_y1()
        && $self->get_x2() >= $c->get_x2()
        && $self->get_y2() >= $c->get_y2();
}

=head2 is_inside

Return true if the coordinates is inside the given coordinates

  my $boolean = $self->is_inside( $coord )

  input  : a Curses::Toolkit::Object::Coordinates object : the coordinates
  output : true or false

=cut

sub is_inside {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );
    return $c->contains($self);
}

=head2 is_in_widget

Return true if the coordinates is inside the given widget

  input  : Curses::Toolkit::Widget : the widget
  output : true or false

=cut

sub is_in_widget {
    my ( $self, $widget ) = @_;
    my $w_coord = $widget->get_coordinates();
    return
           $w_coord->get_x1() <= $self->get_x1()
        && $w_coord->get_x2() >= $self->get_x2()
        && $w_coord->get_y1() <= $self->get_y1()
        && $w_coord->get_y2() >= $self->get_y2();
}


1;
