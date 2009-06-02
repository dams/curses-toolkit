package Curses::Toolkit::Event::Shape;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Event);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Event::Shape - events that are related to root window shape change

=head1 DESCRIPTION

Base class for events

=head1 CONSTRUCTOR

=head2 new

  input : type   : a type of Shape Event. STRING, should be one of Curses::Toolkit::Event::Shape->get_types()
          params : parameter of the event. Can be optional or mandatory. Call Curses::Toolkit::Event::Shape->get_params_definition($type) to see

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	my %args = validate( @_,
						 { type => 
						   { type => SCALAR,
							 callbacks => { 'must be one of ' . join(', ', $self->get_types()) =>
											sub { my %h = map { $_ => 1 } $self->get_types(); $h{ $_[0] }; },
										  }
						   },
						   params => 0,
						 }
					   );
	my @args = $args{params};
	my ($params) = validate_pos( @args, $self->get_params_definition($args{type}) ),
	$self->{type}   = $args{type};
	$self->{params} = $params;
	return $self;
}

=head1 METHODS

=head2 get_type

  my $type = $event->get_type();

Returns the type of the event.

=head2 get_types

Returns the types that this Event Class supports

  input  : none
  output : ARRAY of string.

=cut

my %types = ( change => 0,
			  hide => 0,
			  show => 0,
			  destroy => 0,
			);
sub get_types {
	my ($self) = @_;
	return keys %types;
}

=head2 get_params_definition

Returns the parameter definition for a given type, as specified in Params::Validate

  input  : the type name
  output : 0 OR 1 OR HASHREF

=cut

sub get_params_definition {
	my ($self, $type) = @_;
	return $types{type};
}

1;
