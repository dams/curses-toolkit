use warnings;
use strict;

package Curses::Toolkit::Object::Shape;

# ABSTRACT: simple shape class

use parent qw(Curses::Toolkit::Object::Coordinates);

use Params::Validate qw(:all);

=head1 DESCRIPTION

The Shape is the root window area. 
This module is the class implementing the Shape.

Technically, a Shape is a ReadOnly Coordinate, plus some members, states, flags, and methods.

You can have a look at L<Curses::Toolkit::Object::Coordinates>.

=head1 CLASS METHODS

Nothing more than L<Curses::Toolkit::Object::Coordinates> for now

=cut

# Making it readonly

sub set         { _die() }
sub add         { _die() }
sub subtract   { _die() }
sub restrict_to { _die() }

sub _die {
    die " You should not be calling '" . ( caller(1) )[3] . "' on a '" . __PACKAGE__ . "' object, as it's read only.";
}

# private methods

sub _set {
    my $self = shift;
    $self->SUPER::set(@_);
}


1;
