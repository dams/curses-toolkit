package Curses::Toolkit::Widget::Label;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(:all);
use List::Util qw(min max);

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
	$self->{justification} = 'left';
	$self->{wrap_method} = 'word';
	$self->{wrap_mode} = 'lazy';
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
	$self->needs_redraw();
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

  input  : STRING, one of 'left', 'right', 'center'
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
  output : STRING, one of 'left', 'right', 'center'

=cut

sub get_justify {
	my ($self) = @_;
	return $self->{justification};
}

=head2 set_wrap_mode

Set the wrap mode. 'never' means the label stay on one line (cut if not enough
space is available), paragraphs are not interpreted. 'active' means the label tries to occupy space vertically
(thus wrapping instead of extending to the right). 'lazy' means the label wraps
if it is obliged to (not enough space to display on the same line), and on paragraphs

  input  : STRING, one of 'never', 'active', 'lazy'
  output : the label widget

=cut

sub set_wrap_mode {
	my $self = shift;
	my ($wrap_mode) = validate_pos( @_, { regex => qr/^(?:never|active|lazy)$/ } );
	$self->{wrap_mode} = $wrap_mode;
	return $self;
}

=head2 get_wrap_mode

Get the text wrap mode ofthe label widget.

  input  : none
  output : STRING, one of 'never', 'active', 'lazy'

=cut

sub get_wrap_mode {
	my ($self) = @_;
	return $self->{wrap_mode};
}

=head2 set_wrap_method

Set the wrap method used. 'word' (the default) wraps on word. 'letter' makes
the label wrap but at any point.

  input  : STRING, one of 'word', 'letter'
  output : the label widget

=cut

sub set_wrap_method {
	my $self = shift;
	my ($wrap_method) = validate_pos( @_, { regex => qr/^(?:word|letter)$/ } );
	$self->{wrap_method} = $wrap_method;
	return $self;
}

=head2 get_wrap_method

Get the text wrap method inside the label widget.

  input  : none
  output : STRING, one of 'word', 'letter'

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

	foreach my $y ( 0..min($#text, $c->height() - 1) ) {
		my $t = $text[$y];
		$t =~ s/^\s+//g;
		$t =~ s/\s+$//g;
		if ($justify eq 'left') {
			$theme->draw_string($c->x1(), $c->y1() + $y, $t);
		}
		if ($justify eq 'center') {
			$theme->draw_string($c->x1() + ($c->width() - length $t ) / 2,
								$c->y1() + $y,
								$t);
		}
		if ($justify eq 'right') {
			$theme->draw_string($c->x1() + $c->width() - length $t,
								$c->y1() + $y,
								$t);
		}
	}
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
The Label desires the minimum space that lets it display entirely

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my $self = shift;
	return $self->get_minimum_space(@_);
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
	my ($self, $available_space) = @_;

	my $minimum_space = $available_space->clone();
	my $wrap_mode = $self->get_wrap_mode();
	my $text = $self->get_text();
	if ($wrap_mode eq 'never') {
		$text =~ s/\n(\s)/$1/g;
		$text =~ s/\n/ /g;
		$minimum_space->set( x2 => $available_space->x1() + length $text,
							 y2 => $available_space->y1() + 1,
						   );
		return $minimum_space;
	} elsif ($wrap_mode eq 'active') {
		my $width = 1;
		while (1) {
			{ open my $f, ">>/tmp/__foo__"; print $f " width = $width \n"; }
			my @text = _textwrap($self->get_text(), $width);
			{ open my $f, ">>/tmp/__foo__"; print $f " text : " . scalar(@text) . "\n"; }
			{ open my $f, ">>/tmp/__foo__"; print $f " HEIGHT: " . $available_space->height() . "\n"; }
			if ($width >= length($self->get_text())) {
				$minimum_space->set( x2 => $minimum_space->x1() + length($self->get_text()) + 1,
									 y2 => $minimum_space->y1() + 1 );
				last;
			}
			if (@text < 1  || @text > $available_space->height()) {
				$width++;
				next;
			}
			{ open my $f, ">>/tmp/__foo__"; print $f " setting to : " . ( $minimum_space->x1() + max(map { length } @text )) . "\n      - " . ($minimum_space->y1() + $#text) . "\n"; }
			$minimum_space->set( x2 => $minimum_space->x1() + max(map { length } @text ) + 1,
								 y2 => $minimum_space->y1() + scalar(@text) );
			last;
		}
		return $minimum_space;
	} elsif ($wrap_mode eq 'lazy') {
		my @text = _textwrap($self->get_text(), max($available_space->width(), 1));
		$minimum_space->set( y2 => $minimum_space->y1() + scalar(@text) );
		$minimum_space->set( x2 => $minimum_space->x1() + max(map { length } @text ) );
		return $minimum_space;
	}
	die;
}
1;
