use warnings;
use strict;

package Curses::Toolkit::Role;

=head1 NAME

Curses::Toolkit::Role - base class for roles, before migrating to Moose

=head1 DESCRIPTION

Base class for Roles. Thiw will disappear once I use Moose and don't need
multiple inheriatance anmore.

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my ($class) = shift;
    # TODO : use Exception;
    $class eq __PACKAGE__ and die "abstract class";
}

1;
