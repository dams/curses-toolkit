use warnings;
use strict;

package Curses::Toolkit::Widget::VScrollBar;

# ABSTRACT: a vertical scrollbar widget

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

This widget is just the vertical scrollbar. Usually you will want to use 
Curses::Toolkit::Widget::ScrollArea

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::VScrollBar object

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->{visibility_mode} = 'auto';
    return $self;
}

=head1 METHODS

=head2 set_visibility_mode

Set the visibility mode of the scrollbar

  input  : one of 'auto', 'always'
  output : the scrollbar object

=cut

sub set_visibility_mode {
    my $self = shift;
    my ($visibility_mode) = validate_pos( @_, { regex => qr/^(?:auto|always)$/ } );
    $self->{visibility_mode} = $visibility_mode;
    return $self;
}

=head2 get_visibility_mode

Returns the visibility mode of the scrollbar

  input  : none
  output : one of 'auto', 'always'

=cut

sub get_visibility_mode {
    my ($self) = @_;
    return $self->{visibility_mode};
}

sub draw {
    my ($self) = @_;
    my $theme = $self->get_theme();
    my $c = $self->get_coordinates();

#    print STDERR "\n\n----------------\n\n";
#    print STDERR Dumper($c); use Data::Dumper;
    $theme->draw_string( 0, 0, 'PLOP');
    $theme->draw_string( $c->get_x1(), $c->get_y1(), '^');
    $theme->draw_vline( $c->get_x1(), $c->get_y1()+1, $c->height()-2);
    $theme->draw_string( $c->get_x1(), $c->get_y2()-1, 'v');
    return;
}


1;
