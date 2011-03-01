use warnings;
use strict;

package Curses::Toolkit::Signal;

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 NAME

Curses::Toolkit::Signal - base class for signals

=head1 DESCRIPTION

Base class for signals

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my $class = shift;
    $class eq __PACKAGE__ and die "abstract class";
    return bless {}, $class;
}

# returns the type of the signal
sub get_type {
    my ($self) = @_;
    return $self->{type};
}

1;
