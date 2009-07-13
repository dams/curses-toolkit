package Curses::Toolkit::Widget::Entry;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget Curses::Toolkit::Role::Focusable);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::Entry - an entry widget

=head1 DESCRIPTION

This widget consists of an entry

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::Entry object

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->{text} = '';
	$self->{cursor_position} = 0;
	$self->{text_display_offset} = 0;

	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Key',
			conditional_code => sub { 
				my ($event) = @_;
				# accept only key strokes
				$event->{type} eq 'stroke' or return 0;
				# don't accept strange keys
				length $event->{params}{key} == 1 or return 0;
			},
			code => sub {
				my ($event, $entry) = @_;
				$entry->set_text($entry->get_text() . $event->{params}{key});
				$entry->needs_redraw();
			},
		)
	);
	return $self;
}

=head2 new_with_text

This creates an entry with text in it.

  input  : STRING, some text
  output : a Curses::Toolkit::Widget::Entry object

=cut

sub new_with_text {
	my $class = shift;
	my ($text) = validate_pos( @_, { type => SCALAR } );
	my $self = $class->new();
	$self->set_text( $text );
	return $self;
}

=head1 METHODS

=head2 set_text

Set the text of the entry

  input  : STRING, the text
  output : the entry object

=cut

sub set_text {
	my $self = shift;
	
	my ($text) = validate_pos( @_, { type => SCALAR } );
	$self->{text} = $text;
	return $self;

}

=head2 get_text

Get the text of the Entry

  input  : none
  output : STRING, the Entry text

=cut

sub get_text {
	my ($self) = @_;
	return $self->{text};
}

# <--- w1 -->
#  <-- w2 ->
# [some text]
# -^  o1 
# ---- o2 --^ 


=head2 draw

=cut

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();
	my $c = $self->get_coordinates();
	my $text = $self->get_text();

# TODO : theme this !
	my $w1 = $c->width();
	my $w2 = $w1 - 2;
	my $o1 = 1;
	my $o2 = $w1 - 1;

	# prepare the background text
	my $display_text = '_' x $w2;
	# get the text to display
	my $t = substr($text, $self->{text_display_offset}, $w2);
print STDERR " --> t : $t\n";
	# put the background text below it
print STDERR " --> t : $display_text\n";
	substr($display_text, 0, length($t)) = $t;
print STDERR " --> t : $t\n";

	$theme->draw_string($c->x1(), $c->y1(), '[');
	$theme->draw_string($c->x1() + $o2, $c->y1(), ']');
	$theme->draw_string($c->x1() + $o1, $c->y1(), $display_text);

	return;
}

=head2 get_desired_space

Given a coordinate representing the available space, returns the space desired
The Entry desires 12x1

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_desired_space {
	my ($self, $available_space) = @_;

	my $desired_space = $available_space->clone();
	$desired_space->set( x2 => $available_space->x1() + 12,
						 y2 => $available_space->y1() + 1,
					   );
	return $desired_space;
	
}

=head2 get_minimum_space

Given a coordinate representing the available space, returns the minimum space
needed to properly display itself.
The Entry requires 3x1 minimum

  input : a Curses::Toolkit::Object::Coordinates object
  output : a Curses::Toolkit::Object::Coordinates object

=cut

sub get_minimum_space {
	my ($self, $available_space) = @_;

	my $minimum_space = $available_space->clone();
	$minimum_space->set( x2 => $available_space->x1() + 3,
						 y2 => $available_space->y1() + 1,
					   );
	return $minimum_space;
}

1;
