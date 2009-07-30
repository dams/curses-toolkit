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

	# by default in non edit mode
	$self->{edit_mode} = 0;

#	# default entry width
#	$self->{width} = $self->get_theme_property('default_width');

	# set a key listener, disabled by default
	$self->{key_listener} =
	  Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Key',
			conditional_code => sub { 
				my ($event) = @_;
				# accept only key strokes
				$event->{type} eq 'stroke' or return 0;
				$event->{params}{key} eq '<KEY_BACKSPACE>' and return 1;
				$event->{params}{key} eq '<^D>' and return 1;
				$event->{params}{key} eq '<KEY_LEFT>' and return 1;
				$event->{params}{key} eq '<KEY_RIGHT>' and return 1;
				$event->{params}{key} eq '<KEY_UP>' and return 1;
				$event->{params}{key} eq '<KEY_DOWN>' and return 1;
				if ($event->{params}{key} eq '<^?>') {
					$event->{params}{key} = '<KEY_BACKSPACE>';
					return 1;
				}
				if ($event->{params}{key} eq '<^E>') {
					$event->{params}{key} = '<KEY_DOWN>';
					return 1;
				}
				if ($event->{params}{key} eq '<^A>') {
					$event->{params}{key} = '<KEY_UP>';
					return 1;
				}

				# accept simple character keys
				length $event->{params}{key} == 1 and return 1;

				# don't accept other strange keys
				return 0;
			},
			code => sub {
				my ($event, $entry) = @_;
				my $k = $event->{params}{key};
				my $c = $entry->get_cursor_position();
				my $t = $entry->get_text();
				if ($k eq '<KEY_LEFT>') {
					$entry->move_cursor_position(-1);
				} elsif ($k eq '<KEY_RIGHT>') {
					$entry->move_cursor_position(1);
				} elsif ($k eq '<KEY_UP>') {
					$entry->set_cursor_position(0);
				} elsif ($k eq '<KEY_DOWN>') {
					$entry->set_cursor_position(length($t));
				} elsif ($k eq '<KEY_BACKSPACE>') {
					if ($c > 0) {
						substr($t, $c - 1, 1) = '';
						$entry->set_text($t);
						$entry->move_cursor_position(-1);
					}
				} elsif ($k eq '<^D>') {
					if ($c < length($t)) {
						substr($t, $c, 1) = '';
						$entry->set_text($t);
					}
				} else {
					substr($t, $c, 0 ) = $k;
					$entry->set_text($t);
					$entry->move_cursor_position(length($k));
				}
				$entry->needs_redraw();
			},
		);
	$self->{key_listener}->disable();
	$self->add_event_listener(
		$self->{key_listener},
	);

	# listen to the Enter key
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Key',
			conditional_code => sub { 
				my ($event) = @_;
				$event->{type} eq 'stroke' or return 0;
				$event->{params}{key} eq '<^M>' or return 0;
				return 1;
			},
			code => sub {
				my ($event, $entry) = @_;
				$entry->set_edit_mode(! $entry->get_edit_mode());
			},
		)
	);

	# listen to the Focus Out event
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Focus::Out',
			conditional_code => sub { 
				my ($event) = @_;
				return 1;
			},
			code => sub {
				my ($event, $entry) = @_;
				$entry->set_edit_mode(0);
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
	$self->set_cursor_position( length($text) );
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

# =head2 set_width

# Set the width of the visible text in the entry

#   input  : the width (positive integer)
#   output : the widget

# =cut

# sub set_width {
# 	my $self = shift;
# 	my ($width) = validate_pos( @_, { type => SCALAR,
# 									}
# 							  );
# 	$self->{width} = $width;
# 	return $self;
# }

# =head2 get_width

# Get the width of the visible text in the entry

#   input  : none
#   output : the width

# =cut

# sub get_width {
# 	my ($self) = @_;
# 	return $self->{width};
# }


=head2 set_edit_mode

Set the entry to be in edit mode or not

input  : true or false
output : the entry widget

=cut

sub set_edit_mode {
	my ($self, $bool) = @_;
	my $old_bool = $self->get_edit_mode();
	if ($bool && !$old_bool) {
		# switched to edit mode
		$self->{key_listener}->enable();
		$self->{edit_mode} = 1;
		$self->needs_redraw();
	}
	if (!$bool && $old_bool) {
		# switched to non-edit mode
		$self->{key_listener}->disable();
		$self->{edit_mode} = 0;
		$self->needs_redraw();
	}
	return $self;
}

=head2 get_edit_mode

Returns true if the entry is in edit mode, false otherwise

input  : none
output : true or false

=cut

sub get_edit_mode {
	my ($self) = @_;
	return $self->{edit_mode};
}

=head2 set_cursor_position

Set absolute position of the cursor

  input  : the cursor position
  output : the entry widget;

=cut

sub set_cursor_position {
	my $self = shift;
	my ($position) = validate_pos(@_, { type => SCALAR });
	$position < 0 and $position = 0;
	$position > length($self->get_text()) and $position = length($self->get_text());
	$self->{cursor_position} = $position;
	return $self;
}

=head2 get_cursor_position

Returns the absolute position of the cursor

  input  : none
  output : the cursor position

=cut

sub get_cursor_position {
	my $self = shift;
	return $self->{cursor_position};
}

=head2 move_cursor_position

Set the position of the cursor, relatively

  input  : cursor deplacement (can be positive or negative)
  output : the entry widget

=cut

sub move_cursor_position {
	my $self = shift;
	my ($rel_position) = validate_pos(@_, { type => SCALAR });
	my $position = $self->get_cursor_position() + $rel_position;
	return $self->set_cursor_position($position);
}

=head2 draw

=cut

# <--- w1 -->
#  <-- w2 ->
# [some text]
# -^  o1 
# ---- o2 --^ 

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

	if ( ! $self->get_edit_mode() ) {
		my $t = substr($text, 0, $w2);
print STDERR " --> t : $t\n";
		# put the background text below it
print STDERR " --> t : $display_text\n";
		substr($display_text, 0, length($t)) = $t;
print STDERR " --> t : $t\n";

		$theme->draw_string($c->x1(), $c->y1(), '[');
		$theme->draw_string($c->x1() + $o2, $c->y1(), ']');
		$theme->draw_string($c->x1() + $o1, $c->y1(), $display_text);

	} else {
		if ( $self->get_cursor_position() >= $self->{text_display_offset} + $w2 - 1) {
			$self->{text_display_offset} = $self->get_cursor_position() - $w2 + 1;
		}
		if ( $self->get_cursor_position() < $self->{text_display_offset}) {
			$self->{text_display_offset} = $self->get_cursor_position();
		}
		my $t = substr($text, $self->{text_display_offset}, $w2);
		substr($display_text, 0, length($t)) = $t;
		my $relative_cursor_position = $self->get_cursor_position() - $self->{text_display_offset};
		my $t1 = substr($display_text, 0, $relative_cursor_position);
		my $t2 = substr($display_text, $relative_cursor_position, 1);
		my $t3 = substr($display_text, $relative_cursor_position + 1);

		$theme->draw_string($c->x1(), $c->y1(), '[', { reverse => 0 });
		$theme->draw_string($c->x1() + $o2, $c->y1(), ']', { reverse => 0 });
		$theme->draw_string($c->x1() + $o1, $c->y1(), $t1, { reverse => 0 });
		$theme->draw_string($c->x1() + $o1 + length($t1), $c->y1(), $t2, { reverse => 1 } );
		$theme->draw_string($c->x1() + $o1 + length($t1) + 1, $c->y1(), $t3, { reverse => 0 } );
	}


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
#	$desired_space->set( x2 => $available_space->x1() + $self->get_width(),
	$desired_space->set( x2 => $available_space->x2(),
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

# =head1 Theme related properties

# To set/get a theme properties, you should do :

# $entry->set_theme_property(property_name => $property_value);
# $value = $entry->get_theme_property('property_name')

# Here is the list of properties related to the entry, that can be changed in
# the associated theme. See the Curses::Toolkit::Theme class used for the default
# (default class to look at is Curses::Toolkit::Theme::Default)

# Don't forget to look at properties from the parent class, as these are also
# inherited of !

# =head2 default_width

# Sets the value of the width of the entry by default.

# =cut

# sub _get_theme_properties_definition {
# 	my ($self) = @_;
# 	return { %{$self->SUPER::_get_theme_properties_definition() },
# 			 default_width => {
# 			   optional => 0,
# 			   type => SCALAR,
# 			   callbacks => { "positive integer" => sub { $_[0] >= 0 } }
# 			 },
# 		   }
# }

1;
