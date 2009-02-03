package Curses::Toolkit::Widget::Label;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::Label - a label widget

=head1 DESCRIPTION

This widget consists of a text label

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Label object

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->{text} = '';
	$self->{justification} = 'center';
	return $self;
}

=head1 METHODS

=head2 set_text

Set the text of the label

  input  : the text
  output : the label object

=cut

sub set_text {
	my $self = shift;
	
	my ($text) = validate_pos( @_, { type => SCALAR } );
	$self->{text} = $text;
	return $self;

}

=head2 get_text

Get the text of the Label

  input  : none
  output : STRING, the Label text

=cut

sub get_text {
	my ($self) = @_;
	return $self->{text};
}

=head2 set_justify

Set the text justification inside the label widget.

  input  : STRING, one of 'left', 'right', 'center', 'fill'
  output : the label object

=cut

sub set_justify {
	my $self = shift;
	my ($justification) = validate_pos( @_, { regex => qr/^(?:left|center|right)$/ } );
	$self->{justification} = $justification;
	return $self;
}

=head2 get_justify

Get the text justification inside the label widget.

  input  : none
  output : STRING, one of 'left', 'right', 'center', 'fill'

=cut

sub get_justify {
	my ($self) = @_;
	return $self->{justification};
}

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	my $text = $self->get_text();

print STDERR "draw '$text' \n";
	my $justify = $self->get_justify();
# 	if ($justify eq 'left') {
		
# 	} elsif ($justify eq 'right') {

# 	} elsif ($justify eq 'center') {

# 	} elsif ($justify eq 'fille') {

# 	}

	$theme->draw_string($c->{x1}, $c->{y1}, $text);

}

sub get_desired_space {
	my ($self, $available_space) = @_;
	my $desired_space = $available_space->clone();
	$desired_space->set( y2 => $desired_space->y1() );
	return $desired_space;
}
1;
