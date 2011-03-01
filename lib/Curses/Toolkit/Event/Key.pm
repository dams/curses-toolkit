use warnings;
use strict;

package Curses::Toolkit::Event::Key;

# ABSTRACT: event that is related to keystrokes

use parent qw(Curses::Toolkit::Event);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

Event that is related to keystrokes

=head1 CONSTRUCTOR

=head2 new

  input : type   : a type of Key Event. STRING, should be one of Curses::Toolkit::Event::Key->get_types()
          params : parameter of the event. Can be optional or mandatory. Call Curses::Toolkit::Event::Key->get_params_definition($type) to see
          root_window : the root window

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    my %args  = validate(
        @_,
        {   type => {
                type      => SCALAR,
                callbacks => {
                    'must be one of ' . join( ', ', $self->get_types() ) => sub {
                        my %h = map { $_ => 1 } $self->get_types(); $h{ $_[0] };
                    },
                }
            },
            params      => 0,
            root_window => { isa => 'Curses::Toolkit' },
        },
    );
    $args{params} ||= {};
    my @args       = $args{params};
    my $definition = $self->get_params_definition( $args{type} );
    my %params     = validate( @args, $definition ), $self->{type} = $args{type};
    $self->{root_window} = $args{root_window};
    $self->{params}      = \%params;
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

my %types = (
    stroke => {
        key => {
            type      => SCALAR,
            callbacks => {
                non_empty => sub { length( $_[0] ) }
            }
        }
    },
    press   => {},
    release => {},
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
    my ( $self, $type ) = @_;
    return $types{$type};
}

=head2 get_matching_widget

Returns the widget that is affected by the event. In this case, it returns the
widget that currently has the focus

  input  : none
  output : the widget that is affected by the event

=cut

sub get_matching_widget {
    my ($self) = @_;
    my $root = $self->{root_window};
    my $widget;
    defined $widget
        or $widget = $root->get_focused_widget();
    defined $widget
        or $widget = $root->get_focused_window();
    defined $widget
        or $widget = $root;
    return $widget;
}

1;
