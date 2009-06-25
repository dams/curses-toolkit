package Curses::Toolkit::Event::Shape;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Event);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Event::Shape - event that is related to root window shape change

=head1 DESCRIPTION

Event that is related to root window shape change

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
						   root_window => { isa => 'Curses::Toolkit' },
						 }
					   );
	$args{params} ||= {};
	my @args = $args{params};
	my $definition = $self->get_params_definition($args{type});
	my %params = validate( @args, $definition ),
	$self->{type}   = $args{type};
	$self->{root_window}   = $args{root_window};
	$self->{params} = \%params;
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

my %types = ( change => { },
			  hide => {},
			  show => {},
			  destroy => {},
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
	return $types{$type};
}

=head2 get_matching_widget

Returns the widget that is affected by the event. In this case, it returns root
window, because Shape event is only related to the root window

  input  : none
  output : the root window

=cut

sub get_matching_widget {
	my ($self) = @_;
	return $self->{root_window};
}

1;
