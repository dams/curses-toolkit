use warnings;
use strict;

package Curses::Toolkit::Widget::Label;

# ABSTRACT: a container with two panes arranged horizontally

use parent qw(Curses::Toolkit::Widget);

use Params::Validate qw(:all);
use List::Util qw(min max);
use Curses::Toolkit::Object::MarkupString;

=head1 DESCRIPTION

This widget consists of a text label. This widget is more powerful than it
seems : it supports line wrapping, and color, bold, underline, etc.

=head1 MARKUPS SUPPORT

To be able to have more than simple text, the Label widget supports markup tags
in its text, for example :

  'foo <u>underlined bar</u> <span fgcolor="blue"> blue text <span
   bgcolor="red"> blue on red </span> normal on red </span> <b>bold</b>.'

=over

=item <u>

  <u>underlined string</u>

The <u> tag makes the enclosing text underlined

=item <b>

  <b>bold string</b>

The <b> tag makes the enclosing text bold

=item <span>

The <span> tag allows more attributes to be set. Attributes can of course be combined :

  <span wight="blink" fgcolor="black" bgcolor="red">Warning text!</span>

There is the list of attributes :

=over

=item weight

  <span weight="reverse">some reverse string</span>

Specifies display attributes. Weight values can be :

  normal : force some text back to normal
  standout : enable standout property
  underline : enable underline property
  blink : enable blink property
  dim : enable dim property
  bold : enable bold property

Somme properties may be unsupported on your terminal.

=item fgcolor

  <span fgcolor="blue">some blue text</span>

Change the foreground color. values can be :

  black
  red
  green
  yellow
  blue
  magenta
  cyan
  white

=item bgcolor

  <span bgcolor="red">some red background text</span>

Change the foreground color. values can be :

  black
  red
  green
  yellow
  blue
  magenta
  cyan
  white

=back

=back

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Label object

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->{text}          = '';
    $self->{justification} = 'left';
    $self->{wrap_method}   = 'word';
    $self->{wrap_mode}     = 'lazy';
    return $self;
}

=head1 METHODS

=head2 set_text

Set the text of the label. The text can be either normal text, or text with
markups, to display colors, bold, underline, etc., see Markup Support above

  input  : the text
  output : the label object

=cut

sub set_text {
    my $self = shift;

    my ($text) = validate_pos( @_, { type => SCALAR } );
    $self->{text}           = $text;
    $self->{_markup_string} = Curses::Toolkit::Object::MarkupString->new($text);
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
    my $theme  = $self->get_theme();
    my $c      = $self->get_coordinates();
    my $text   = $self->{_markup_string}->stripped();

    my $justify = $self->get_justify();

    my $wrap_method = $self->get_wrap_method();

    my @text = _textwrap( $self->{_markup_string}, $c->width() );

    foreach my $y ( 0 .. min( $#text, $c->height() - 1 ) ) {
        my $t = $text[$y];
        $t->search_replace( '^\s+', '' );
        $t->search_replace( '\s+$', '' );
        if ( $justify eq 'left' ) {
            $theme->draw_string( $c->get_x1(), $c->get_y1() + $y, $t );
        }
        if ( $justify eq 'center' ) {
            $theme->draw_string(
                $c->get_x1() + ( $c->width() - length $t ) / 2,
                $c->get_y1() + $y,
                $t
            );
        }
        if ( $justify eq 'right' ) {
            $theme->draw_string(
                $c->get_x1() + $c->width() - length $t,
                $c->get_y1() + $y,
                $t
            );
        }
    }
}


sub _textwrap {
    my $text = shift;
    my $columns = shift || 1;
    my ( @tmp, @rv, $p );

    # Early exit if no text was passed
    return unless ( defined $text && $text->stripped_length() );

    # Split the text into paragraphs, but preserve the terminating newline
    @tmp = $text->split_string("\n");
    foreach my $t (@tmp) {
        $t->append("\n");
    }

    $tmp[-1]->chomp_string() unless $text->stripped() =~ /\n$/;

    # Split each paragraph into lines, according to whitespace
    for $p (@tmp) {

        # Snag lines that meet column limits (not counting newlines
        # as a character)
        if ($p->stripped_length() <= $columns
            || (   $p->stripped_length() - 1 <= $columns
                && $p->stripped() =~ /\n$/s )
            )
        {
            push( @rv, $p );
            next;
        }

        # Split the line
        while ( $p->stripped_length() > $columns ) {
            if ( $p->substring( 0, $columns )->stripped() =~ /^(.+\s)(\S+)$/ ) {
                my ( $v1, $v2 ) = ( $1, $2 );
                push( @rv, $p->substring( 0, length($v1) ) );
                my $l  = $p->stripped_length();
                my $m1 = $p->substring( length($v1), length($v2) );
                my $m2 = $p->substring( $columns, $l - $columns );
                $m1->append($m2);
                $p = $m1;
            } else {
                push( @rv, $p->substring( 0, $columns ) );
                $p = $p->substring( $columns, $p->stripped_length() - $columns );
            }
        }

        push( @rv, $p );
    }

    if ( $text->stripped() =~ /\S\n(\n+)/ ) {
        my $l = length($1);
        foreach ( 1 .. $l ) { push( @rv, Curses::Toolkit::Object::MarkupString->new("\n") ) }
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
    my ( $self, $available_space ) = @_;
    return $self->_get_space($available_space, $self->get_wrap_method);
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
    my ( $self, $available_space ) = @_;
    return $self->_get_space($available_space, 'active');
}

sub _get_space {
    my ( $self, $available_space ) = @_;

    my $minimum_space = $available_space->clone();
    my $wrap_mode     = $self->get_wrap_mode();
    my $text          = $self->{_markup_string}->stripped();
    if ( $wrap_mode eq 'never' ) {
        $text =~ s/\n(\s)/$1/g;
        $text =~ s/\n/ /g;
        $minimum_space->set(
            x2 => $available_space->get_x1() + length $text,
            y2 => $available_space->get_y1() + 1,
        );
        return $minimum_space;
    } elsif ( $wrap_mode eq 'active' ) {
        my $width = 1;
        while (1) {
            my @text = _textwrap( $self->{_markup_string}, $width );
            if ( $width >= $self->{_markup_string}->stripped_length() ) {
                $minimum_space->set(
                    x2 => $minimum_space->get_x1() + $self->{_markup_string}->stripped_length() + 1,
                    y2 => $minimum_space->get_y1() + 1
                );
                last;
            }
            if ( @text < 1 || @text > $available_space->height() ) {
                $width++;
                next;
            }
            $minimum_space->set(
                x2 => $minimum_space->get_x1() + max( map { $_->stripped_length() } @text ) + 1,
                y2 => $minimum_space->get_y1() + scalar(@text)
            );
            last;
        }
        return $minimum_space;
    } elsif ( $wrap_mode eq 'lazy' ) {
        my @text = _textwrap( $self->{_markup_string}, max( $available_space->width(), 1 ) );
        $minimum_space->set( y2 => $minimum_space->get_y1() + scalar(@text) );
        $minimum_space->set( x2 => $minimum_space->get_x1() + max( map { $_->stripped_length() } @text ) );
        return $minimum_space;
    }
    die;

}


1;
