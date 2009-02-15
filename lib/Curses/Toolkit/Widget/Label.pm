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
	$self->{wrap_method} = 'word';
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

=head2 set_wrap_method

Set the wrap method used. 'word' (the default) wraps on word. 'letter' makes
the label wrap but at any point. 'none' makes the label stay on one line (cut
if not enough space is available)

  input  : STRING, one of 'word', 'letter', 'none'
  output : the label object

=cut

sub set_wrap_method {
	my $self = shift;
	my ($wrap_method) = validate_pos( @_, { regex => qr/^(?:word|letter|none)$/ } );
	$self->{wrap_method} = $wrap_method;
	return $self;
}

=head2 get_wrap_method

Get the text wrap method inside the label widget.

  input  : none
  output : STRING, one of 'word', 'letter', 'none'

=cut

sub get_wrap_method {
	my ($self) = @_;
	return $self->{wrap_method};
}

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	my $text = $self->get_text();

	my $justify = $self->get_justify();

	my $wrap_method = $self->get_wrap_method();

	my @text = _textwrap($text, $c->width());

	foreach my $y (0..$c->height() - 1) {
		$theme->draw_string($c->{x1}, $c->{y1} + $y, $text[$y]);
	}
# 	if ($justify eq 'left') {
		
# 	} elsif ($justify eq 'right') {

# 	} elsif ($justify eq 'center') {

# 	} elsif ($justify eq 'fille') {

# 	}

#	$theme->draw_string($c->{x1}, $c->{y1}, $text);

}


sub _textwrap {
  my $text = shift;
  my $columns = shift || 72;
  my (@tmp, @rv, $p);

  # Early exit if no text was passed
  return unless (defined $text && length($text));

  # Split the text into paragraphs, but preserve the terminating newline
  @tmp = split(/\n/, $text);
  foreach (@tmp) { $_ .= "\n" };
  chomp($tmp[$#tmp]) unless $text =~ /\n$/;

  # Split each paragraph into lines, according to whitespace
  for $p (@tmp) {

    # Snag lines that meet column limits (not counting newlines
    # as a character)
    if (length($p) <= $columns || (length($p) - 1 <= $columns &&
      $p =~ /\n$/s)) {
      push(@rv, $p);
      next;
    }

    # Split the line
    while (length($p) > $columns) {
      if (substr($p, 0, $columns) =~ /^(.+\s)(\S+)$/) {
        push(@rv, $1);
        $p = $2 . substr($p, $columns);
      } else {
        push(@rv, substr($p, 0, $columns));
        substr($p, 0, $columns) = '';
      }
    }
    push(@rv, $p);
  }

  if ($text =~ /\S\n(\n+)/) {
    $p = length($1);
    foreach (1..$p) { push(@rv, "\n") };
  }

  return @rv;
}


=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The Label desires the minimum space that let's it display entirely

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my ($self, $available_space) = @_;
	my $desired_space = $available_space->clone();
	my @text = _textwrap($self->get_text(), $available_space->width());
	$desired_space->set( y2 => $desired_space->y1() + $#text );
	return $desired_space;
}
1;
