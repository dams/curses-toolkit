use warnings;
use strict;

package Curses::Toolkit::Object::Coordinates;
# ABSTRACT: simple coordinates class

use Moose;
use MooseX::FollowPBP;
use MooseX::Has::Sugar;

use Params::Validate qw(:all);

extends qw(Curses::Toolkit::Object);

use overload
    '+'  => '_clone_add',
    '-'  => '_clone_subtract',
    '""' => '_stringify',
    '==' => '_equals';


# -- attributes

=attr x1

Top left x coordinate of the object. Can be either an integer or a
coderef.

=attr y1

Top left y coordinate of the object. Can be either an integer or a
coderef.

=attr x2

Bottom right x coordinate of the object. Can be either an integer or a
coderef.

=attr y2

Bottom right y coordinate of the object. Can be either an integer or a
coderef.

=attr normalize

A boolean to swap coordinates to make sure x1 < x2 and y1 < y2 if set to
true (default). If set to false, the coordinates will be untouched.

=cut

has x1 => ( rw, isa=>'Int|CodeRef', required );
has y1 => ( rw, isa=>'Int|CodeRef', required );
has x2 => ( rw, isa=>'Int|CodeRef', required );
has y2 => ( rw, isa=>'Int|CodeRef', required );
has normalize => ( ro, isa=>'Bool', default=>1 );

# if coords are coderef, derefence the callback at query time
around get_x1 => \&_coderef2value;
around get_y1 => \&_coderef2value;
around get_x2 => \&_coderef2value;
around get_y2 => \&_coderef2value;


# -- constructor, builder & initializer

=method new

    my $coord = CTO::Coordinates->new( @attributes );
    my $coord = CTO::Coordinates->new( $coord_to_clone );
    my $coord = CTO::Coordinates->new( x1=>$x1, y1=>$y1, width=>$w, height=>$h );

Constructor for the class. Acceps various kind of attributes.

  input  : x1 : top left x
           y1 : top left y
           x2 : right bottom x
           y2 : right bottom y
           [ normalize ] : optional
    OR
  input  : x1 : top left x
           y1 : top left y
           width : width
           height : height
           [ normalize ] : optional
    OR
  input  : x1 : sub { ... } # returns top left x
           y1 : sub { ... } # returns top left y
           x2 : sub { ... } # returns right bottom x
           y2 : sub { ... } # returns right bottom y
           [ normalize ] : optional
    OR
  input  : a Curses::Toolkit::Object::Coordinates object

  output : a Curses::Toolkit::Object::Coordinates object

=cut

# called before object is built, to normalize the arguments.
sub BUILDARGS {
    my $class  = shift;

    # case: Coordinates->new( $clone );
    if ( ref($_[0]) eq __PACKAGE__ ) {
        my $c    = $_[0];
        my %params = (
            x1 => $c->{x1}, y1 => $c->{y1},
            x2 => $c->{x2}, y2 => $c->{y2},
        );
        return \%params;
    }

    # regular case
    my %params = @_;
    return \%params unless exists $params{width} || exists $params{height};

    # case: width and height arguments
    validate( @_,
        {   x1        => { type     => SCALAR }, y1     => { type => SCALAR },
            width     => { type     => SCALAR }, height => { type => SCALAR },
            normalize => { optional => 1,        type   => BOOLEAN },
        }
    );
    $params{x2} = $params{x1} + $params{width};
    $params{y2} = $params{y1} + $params{height};
    defined $params{normalize} or $params{normalize} = 1;

    return \%params;
}

# called when object has been built
sub BUILD {
    my $self = shift;
    $self->get_normalize and $self->_normalize;
}


=method new_zero

    my $coord = CTO::Coordinates->new_zero;

Creates a new coordinates with all individual coords set to zero.

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


=method clone

    my $c2 = $c1->clone;

Clone a coordinates object.

  input  : none
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub clone {
    my ($self) = @_;
    return ref($self)->new($self);
}


# -- public methods

=method set

    $coord->set( x1=>$x1, y1=>$y1, x2=>$x2, y2=>$y2 );

Set attributes of the coordinate object.

  input  : one or more of x1, x2, y1, y2
  output : the coordinate object

=cut

sub set {
    my $self   = shift;

    # checks on params
    my %params = validate(
        @_,
        {   x1 => { type => SCALAR | CODEREF, optional => 1 }, y1 => { type => SCALAR | CODEREF, optional => 1 },
            x2 => { type => SCALAR | CODEREF, optional => 1 }, y2 => { type => SCALAR | CODEREF, optional => 1 },
        }
    );
    keys %params or die "One of (x1, y1, x2, y2) argument must be passed";

    # set the new coords
    foreach my $k ( keys %params ) {
        my $method = "set_$k";
        $self->$method( $params{$k} );
    }
    $self->_normalize;
    return $self;
}


=method width

    my $width = $coord->width;

Returns the width represented by the coordinate object.

=cut

sub width {
    my ($self) = @_;
    return $self->get_x2() - $self->get_x1();
}


=method height

    my $height = $coord->height;

Returns the height represented by the coordinate object.

=cut

sub height {
    my ($self) = @_;
    return $self->get_y2() - $self->get_y1();
}




=method add

    $coord->add( $const );
    $coord->add( $coord_to_add );
    $coord->add( { x1=>$x1, y1=>$y1, x2=>$x2, y2=>$y2 } );

Add to the coordinate attributes of the object.

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

    # FIXME: callbacks loose their coderef status

    if ( !ref $c ) {
        # argument is a constant
        @{$self}{qw(x1 y1 x2 y2)} = (
            $self->get_x1 + $c, $self->get_y1 + $c,
            $self->get_x2 + $c, $self->get_y2 + $c,
        );

    } elsif ( ref $c eq __PACKAGE__ ) {
        # argument is a coordinate object
        @{$self}{qw(x1 x2 y1 y2)} = (
            $self->get_x1 + $c->get_x1, $self->get_x2 + $c->get_x2,
            $self->get_y1 + $c->get_y1, $self->get_y2 + $c->get_y2,
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


=method subtract

    $coord->subtract( $const );
    $coord->subtract( $coord_to_add );
    $coord->subtract( { x1=>$x1, y1=>$y1, x2=>$x2, y2=>$y2 } );

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

    # FIXME: callbacks loose their coderef status

    if ( !ref $c ) {
        # argument is a constant
        @{$self}{qw(x1 y1 x2 y2)} = (
            $self->get_x1 - $c, $self->get_y1 - $c,
            $self->get_x2 - $c, $self->get_y2 - $c,
        );

    } elsif ( ref $c eq __PACKAGE__ ) {
        # argument is a coordinate object
        @{$self}{qw(x1 x2 y1 y2)} = (
            $self->get_x1 - $c->get_x1, $self->get_x2 - $c->get_x2,
            $self->get_y1 - $c->get_y1, $self->get_y2 - $c->get_y2,
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


=method restrict_to

    $coord->restrict_to( $coord_to_fit_into );

Force the coordinate to be inside the passed coordinate.

  input  : a Curses::Toolkit::Object::Coordinates object
  output : the object

=cut

sub restrict_to {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );

    $self->get_x1 < $c->get_x1 and $self->{x1} = $c->{x1};
    $self->get_x1 > $c->get_x2 and $self->{x1} = $c->{x2};

    $self->get_x2 > $c->get_x2 and $self->{x2} = $c->{x2};
    $self->get_x2 < $c->get_x1 and $self->{x2} = $c->{x1};

    $self->get_y1 < $c->get_y1 and $self->{y1} = $c->{y1};
    $self->get_y1 > $c->get_y2 and $self->{y1} = $c->{y2};

    $self->get_y2 > $c->get_y2 and $self->{y2} = $c->{y2};
    $self->get_y2 < $c->get_y1 and $self->{y2} = $c->{y1};

    return $self;
}


=method grow_to

    $coord->grow_to( $coord_to_match );

Force the coordinate to be at least as big as the passed coordinate.

  input  : a Curses::Toolkit::Object::Coordinates object
  output : the object

=cut

sub grow_to {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );

    $self->get_x1 > $c->get_x1 and $self->{x1} = $c->{x1};
    $self->get_x2 < $c->get_x2 and $self->{x2} = $c->{x2};

    $self->get_y1 > $c->get_y1 and $self->{y1} = $c->{y1};
    $self->get_y2 < $c->get_y2 and $self->{y2} = $c->{y2};

    return $self;
}


=method translate

    $coord->translate( x=>$x, y=>$y );

Given a X value and a Y value, translates the coordinate accordingly

  input  : x : value to translate the coord horizontally
           y : value to translate the coord vertically
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate {
    my $self = shift;

    # FIXME: callbacks loose their coderef status

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


=method translate_up

    $coord->translate_up( $offset );

Given a value, translates the coordinate up (value sign is ignored)

  input  : value to translate the coord up
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_up {
    my ( $self, $value ) = @_;
    return $self->translate( y => -abs $value );
}


=method translate_down

    $coord->translate_down( $offset );

Given a value, translates the coordinate down (value sign is ignored)

  input  : value to translate the coord down
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_down {
    my ( $self, $value ) = @_;
    return $self->translate( y => abs $value );
}


=method translate_left

    $coord->translate_left( $offset );

Given a value, translates the coordinate left (value sign is ignored)

  input  : value to translate the coord left
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_left {
    my ( $self, $value ) = @_;
    return $self->translate( x => -abs $value );
}


=method translate_right

    $coord->translate_right( $offset );

Given a value, translates the coordinate right (value sign is ignored)

  input  : value to translate the coord right
  output : the Curses::Toolkit::Object::Coordinates object

=cut

sub translate_right {
    my ( $self, $value ) = @_;
    return $self->translate( x => abs $value );
}


=method contains

    my $bool = $coord->contains( $coord_to_check );

Return true if the coordinates contains the given coordinates

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


=method is_inside

    my $bool = $coord->is_inside( $coord_to_check );

Return true if the coordinates is inside the given coordinates

  input  : a Curses::Toolkit::Object::Coordinates object : the coordinates
  output : true or false

=cut

sub is_inside {
    my $self = shift;
    my ($c) = validate_pos( @_, { isa => 'Curses::Toolkit::Object::Coordinates' } );
    return $c->contains($self);
}


=method is_in_widget

    my $bool = $coord->is_in_widget( $widget );

Return true if the coordinates is inside the given widget

  input  : Curses::Toolkit::Widget : the widget
  output : true or false

=cut

sub is_in_widget {
    my ( $self, $widget ) = @_;
    my $w_coord = $widget->get_coordinates();
    return
           $w_coord->get_x1 <= $self->get_x1
        && $w_coord->get_x2 >= $self->get_x2
        && $w_coord->get_y1 <= $self->get_y1
        && $w_coord->get_y2 >= $self->get_y2;
}


# -- private methods

#
# my $c3 = $c1->_clone_add( $c2 );
# my $c3 = $c1 + $c2;   # overloaded
#
# clone a coord and add another to the new object.
#
sub _clone_add {
    my $self  = shift;
    my $clone = $self->clone();
    $clone->add(@_);
    return $clone;
}


#
# my $c3 = $c1->_clone_subtract( $c2 );
# my $c3 = $c1 - $c2;   # overloaded
#
# clone a coord and subtract another to the new object.
#
sub _clone_subtract {
    my $self  = shift;
    my $clone = $self->clone();
    $clone->subtract(@_);
    return $clone;
}


#
# don't use this method directly, it's meant to be used as a moose
# around wrapper for the coordinates attributes of the object.
#
sub _coderef2value {
    my $orig = shift;
    my $self = shift;
    my $val = $self->$orig;
    return ref($val) eq 'CODE' ? $val->($self) : $val;
}


#
# my $bool = $c1->_equals( $c2 );
# my $bool = $c1 == $c2;    # overloaded
#
# return true if both $c1 and $c2 point to the same coords. they can
# point to different objects, though.
#
sub _equals {
    my ( $c1, $c2 ) = @_;
    return
           $c1->get_x1 == $c2->get_x1
        && $c1->get_y1 == $c2->get_y1
        && $c1->get_x2 == $c2->get_x2
        && $c1->get_y2 == $c2->get_y2;
}


#
# my $str = $self->_stringify;
# my $str = "$self";     # overloaded
#
# return the string 'WxH+XxY' with:
#   W = width
#   H = height,
#   X = top left x coord
#   Y = top left y coord
#
sub _stringify {
    my ($self) = @_;
    return $self->width . 'x' . $self->height . '+' . $self->get_x1 . 'x' . $self->get_y1;
}


#
# $self->_normalize;
#
# make sure the coordinate is positive. in effect:
#  - swap x1 and x2 to make sure x1 <= x2
#  - swap y1 and y2 to make sure y1 <= y2
#
sub _normalize {
    my ($self) = @_;

    # WARNING: this method assumes that the object is a hashref, which might
    # change with later versions of moose (even if not very probable)
    $self->get_x1() <= $self->get_x2() or ( $self->{x1}, $self->{x2} ) = ( $self->{x2}, $self->{x1} );
    $self->get_y1() <= $self->get_y2() or ( $self->{y1}, $self->{y2} ) = ( $self->{y2}, $self->{y1} );
    return;
}

1;
__END__

=head1 DESCRIPTION

Trivial class to hold 2 points.

+ and - are properly overloaded.
