use warnings;
use strict;

package Curses::Toolkit::Object;
# ABSTRACT: base class for objects

use Moose;

sub BUILDARGS {
    my ($class) = shift;
    # TODO : use Exception;
    $class eq __PACKAGE__ and die "abstract class";
}

1;
__END__

=head1 DESCRIPTION

Base class for objects. This class cannot be instanciated.
