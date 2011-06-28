use warnings;
use strict;

package Curses::Toolkit::Widget::ScrollBar;

use parent qw(Curses::Toolkit::Widget);
use Carp;

sub new {
    my $class = shift;
    $class eq __PACKAGE__
        and die
        "This is an abstract class, please see Curses::Toolkit::Widget::VScrollBar and Curses::Toolkit::Widget::HScrollBar";
    my $self  = $class->SUPER::new();
    $self->{fill} = 1;
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

=head2 set_fill

Set the ratio of the scrollbar that is filled

  input  : ratio number
  output : the scrollbar object

=cut

sub set_fill {
    my ($self, $fill) = @_;
    $fill <= 1 && $fill > 0
      or croak 'argument to set_fill must be greater than 0 and lower or exqual to 1';
    $self->{fill} = $fill;
    return $self;
}

=head2 get_fill

Returns the ratio of te scrollbar that is filled

  input  : none
  output : ratio number

=cut

sub get_fill {
    my ($self) = @_;
    return $self->{fill};
}

1;
