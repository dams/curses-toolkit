use warnings;
use strict;

package Curses::Toolkit::Event::Mouse::Click;

# ABSTRACT: event that is related to mouse click

use parent qw(Curses::Toolkit::Event::Mouse);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

Event that is related to mouse click

=head1 CONSTRUCTOR

=head2 new

  input : type   : a type of mouse click. STRING, can be one of (see below)
          button : the button that was clicked. STRING, can be (see below) 
          coordinates : Curses::Toolkit::Object::Coordinates : where the click happened
          root_window : Curses::Toolkit : the root window object
  
  type can be one of :
  pressed released clicked double_clicked
  triple_clicked shift ctrl alt

  button can be one of :
  button1 button2 button3 button4 button5 button

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    my %args  = validate(
        @_,
        {   type => {
                type      => SCALAR,
                callbacks => {
                    'must be one of ' . join( ', ', $self->get_possible_types() ) => sub {
                        my %h = map { $_ => 1 } $self->get_possible_types(); $h{ $_[0] };
                    },
                },
            },
            button => {
                type      => SCALAR,
                callbacks => {
                    'must be one of ' . join( ', ', $self->get_possible_buttons() ) => sub {
                        my %h = map { $_ => 1 } $self->get_possible_buttons(); $h{ $_[0] };
                    },
                },
            },
            coordinates => { isa => 'Curses::Toolkit::Object::Coordinates' },
            root_window => { isa => 'Curses::Toolkit' },
        }
    );
    $self = bless( \%args, $class );
    return $self;
}

sub get_possible_types {
    my ($self) = @_;
    return qw(pressed released clicked double_clicked triple_clicked shift ctrl alt);
}

sub get_possible_buttons {
    my ($self) = @_;
    return qw(button1 button2 button3 button4 button5 button);
}

=head2 get_matching_widget

Returns the widget that is affected by the event. In this case, it returns the
widget where the click were done

  input  : none
  output : the widget that is affected by the event

=cut

sub get_matching_widget {
    my ($self) = @_;

    my $recurse;
    $recurse = sub {
        my $deepness = shift;
        my $stack    = shift;
        $deepness++;
        my @result = map {
            my $stack = ( $_->isa('Curses::Toolkit::Widget::Window') ? $_->get_property( window => 'stack' ) : $stack );
            [   $deepness,
                $stack,
                $_
            ],
                ( $_->can('get_children') ? $recurse->( $deepness, $stack, $_->get_children() ) : () )
        } @_;
        return @result;
    };

    my @all_widgets = $recurse->( 0, 0, $self->{root_window}->get_windows() );

    # sort by window stack then deepnes in the widget tree
    @all_widgets =
        sort { $b->[1] <=> $a->[1] || $b->[0] <=> $a->[0] }
        grep { $self->{coordinates}->is_in_widget( $_->[2] ) } @all_widgets;


    @all_widgets and return $all_widgets[0]->[2];
    return $self->{root_window};
}

1;
