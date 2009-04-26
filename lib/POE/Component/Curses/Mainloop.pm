package POE::Component::Curses::MainLoop;

use strict;
use warnings;

use POE qw(Session);
use Params::Validate qw(:all);

=head1 NAME

POE::Component::Curses::MainLoop

=head1 SYNOPSIS

This module is not for you !

You should not use this module directly. It's used by L<POE::Component::Curses>
as a MainLoop interface to L<Curses::Toolkit>

Please look at L<POE::Component::Curses>. Thanks !

=cut

# OK so this creates the mainlopp object. IT's the bridge between the POE
# Component and the Curses Toolkit root object.

sub new {
	my $class = shift;

	my %params = validate( @_, { toolkit_root => { optional => 1, isa => 'Curses::Toolkit' },
								 session_name => { optional => 1, type => SCALAR },
							   }
						 );
	# maybe ugly ?
	my $self = bless \%params, $class;

	return $self;
}

sub set_toolkit_root {
	my $self = shift;
    my ($toolkit_root) = validate_pos( @_, { isa => 'Curses::Toolkit' } );
	$self->{toolkit_root} = $toolkit_root;
	return $self;
}

sub set_session_name {
	my ($self) = shift;
	my ($session_name) = validate_pos( @_, { type => SCALAR } );
	return $self;
}

1;
