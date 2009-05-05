package Curses::Toolkit::Event;

use warnings;
use strict;

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Event - base class for events

=head1 DESCRIPTION

Base class for events

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my $class = shift;
    $class eq __PACKAGE__ and die "abstract class";
	return bless { }, $class;
}

# returns the type of the event
sub get_type {
	my ($self) = @_;
	return $self->{type};
}

# by default, an event doesn't apply to nothing. Children classes wil override his

sub spread_to_root_window { 0 }
sub spread_to_windows { 0 }
sub spread_to_widgets { 0 }

1;
