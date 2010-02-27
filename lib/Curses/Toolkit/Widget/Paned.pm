use warnings;
use strict;

package Curses::Toolkit::Widget::Paned;

# ABSTRACT: generic paned widget

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

sub new {
	my $class = shift;

	# TODO : use Exception;
	$class eq __PACKAGE__
		and die
		"This is an abstract class, please see Curses::Toolkit::Widget::HPaned and Curses::Toolkit::Widget::VPaned";
	my $self = $class->SUPER::new(@_);

	# default position
	$self->set_gutter_position(0);

	# listen to the Mouse for moving the gutter
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_events => {
				'Curses::Toolkit::Event::Mouse::Click' => sub {
					my ($event) = @_;
					$event->{button} eq 'button1' or return 0;
					$self->{_gutter_move_pressed} && $event->{type} eq 'released'
						and return 1;
					my $ec = $event->{coordinates};
					my $wc = $self->get_coordinates();
					my $gp = $self->get_gutter_position();

					#	my $gw = $self->get_theme_property('gutter_width');
					my $gw = 1;
					      !$self->{_gutter_move_pressed}
						&& $event->{type} eq 'pressed'
						&& $self->_p1($ec) >= $self->_p1($wc) + $gp
						&& $self->_p1($ec) < $self->_p1($wc) + $gp + $gw
						&& $self->_p2($ec) < $self->_p2($wc)
						and return 1;
					return 0;
				},
			},
			code => sub {
				my ( $event, $widget ) = @_;
				if ( $self->{_gutter_move_pressed} ) {

					# means we released it
					$self->unset_modal();
					my $ec = $event->{coordinates};
					my $wc = $self->get_coordinates();
					$self->set_gutter_position( $self->_p1($ec) - $self->_p1($wc) );

					# changing the gutter position might change the space of
					# the gutter itself, so rebuild starting from the start
					$self->rebuild_all_coordinates();
					$self->needs_redraw();
					$self->{_gutter_move_pressed} = 0;
				} else {

					# means we pressed it
					$self->set_modal();
					$self->needs_redraw();
					$self->{_gutter_move_pressed} = 1;
				}
				return;
			},
		)
	);

	return $self;
}

sub add1 {
	my $self = shift;
	my ($child_widget) = validate_pos(
		@_,
		{ isa => 'Curses::Toolkit::Widget' },
	);
	defined $self->{child1} and die "there is already a child 1";
	$self->_add_child_at_beginning($child_widget);
	$self->{child1} = $child_widget;
	$child_widget->_set_parent($self);
	$self->rebuild_all_coordinates();
	return $self;
}

sub add2 {
	my $self = shift;
	my ($child_widget) = validate_pos(
		@_,
		{ isa => 'Curses::Toolkit::Widget' },
	);
	defined $self->{child2} and die "there is already a child 2";
	$self->_add_child_at_end($child_widget);
	$self->{child2} = $child_widget;
	$child_widget->_set_parent($self);
	$self->rebuild_all_coordinates();
	return $self;
}

sub set_gutter_position {
	my $self = shift;
	my ($position) = validate_pos(
		@_,
		{   type => SCALAR,
		},
	);
	$position < 0 and $position = 0;
	$self->_del_actual_gutter_position();
	$self->{position} = $position;

	return $self;
}

# sets the gutter position, which can be different from the one desired
sub _set_actual_gutter_position {
	my ( $self, $position ) = @_;
	$position < 0 and $position = 0;
	$self->{actual_position} = $position;
	return $self;
}

# deletes the actual gutter position
sub _del_actual_gutter_position {
	my ($self) = @_;
	$self->{actual_position} = undef;
	return $self;
}

sub get_gutter_position {
	my ($self) = @_;
	defined $self->{actual_position}
		and return $self->{actual_position};
	return $self->{position};
}

sub _get_original_gutter_position {
	my ($self) = @_;
	return $self->{position};
}

# =head2 set_gutter_size

# Set the width of the gutter

#   input  : the width (an integer)
#   output : the current widget (not the child widget)

# =cut

# sub set_gutter_size {
# 	my $self = shift;
# 	my ($size) = validate_pos( @_,
# 								   { type => SCALAR,
# 									 callbacks => { positive_integer => { shift() >= 0 } }
# 								   },
# 								 );

# }

sub _rebuild_children_coordinates {
	my ($self) = @_;
	my $available_space = $self->_get_available_space();
	my ( $child1, $child2 ) = $self->get_children();

	#	my $gw = $self->get_theme_property('gutter_width');
	my $gw = 1;
	my $gp = $self->_get_original_gutter_position();
	if ( $gp > ( $self->_p3($available_space) - $gw ) ) {
		$gp = $self->_p3($available_space) - $gw;
		$self->_set_actual_gutter_position($gp);
	} else {
		$self->_del_actual_gutter_position();
	}

	if ( defined $child1 ) {
		my $child1_space = $available_space->clone();
		$child1_space->set( $self->_p4( $child1_space, $gp ) );
		$child1->_set_relatives_coordinates($child1_space);
		$child1->can('_rebuild_children_coordinates')
			and $child1->_rebuild_children_coordinates();
	}
	if ( defined $child2 ) {
		my $child2_space = $available_space->clone();
		$child2_space->set( $self->_p5( $child2_space, $gp, $gw ) );
		$child2->_set_relatives_coordinates($child2_space);
		$child2->can('_rebuild_children_coordinates')
			and $child2->_rebuild_children_coordinates();
	}
	return $self;
}

sub get_desired_space {
	my ( $self,   $available_space ) = @_;
	my ( $child1, $child2 )          = $self->get_children();

	#	my $gw = $self->get_theme_property('gutter_width');
	my $gw = 1;
	my $gp = $self->get_gutter_position();

	# if the gutter is placed over the edge of the space
	if ( $gp > ( $self->_p3($available_space) - $gw ) ) {
		$gp = $self->_p3($available_space) - $gw;
	}

	my $desired_space1 = $available_space->clone();
	$desired_space1->set( $self->_p8( $desired_space1, $gp, $gw ) );
	$desired_space1->set( $self->_p9($available_space) );

	if ( defined $child2 ) {
		my $desired_space2 = $available_space->clone();
		$desired_space2->set( $self->_p5( $available_space, $gp, $gw ) );
		$desired_space2 = $child2->get_desired_space($desired_space2);
		$desired_space2->set( $self->_p10($desired_space1) );
		$desired_space2->set( $self->_p11( $desired_space1, $desired_space2 ) );
		$desired_space2->set( $self->_p9($available_space) );
		return $desired_space2;
	}
	return $desired_space1;
}

sub get_minimum_space {
	my ( $self,   $available_space ) = @_;
	my ( $child1, $child2 )          = $self->get_children();

	#	my $gw = $self->get_theme_property('gutter_width');
	my $gw = 1;
	my $gp = $self->get_gutter_position();

	# if the gutter is placed over the edge of the space
	if ( $gp > ( $self->_p3($available_space) - $gw ) ) {
		$gp = $self->_p3($available_space) - $gw;
	}

	my $minimum_space1 = $available_space->clone();
	$minimum_space1->set( $self->_p8( $minimum_space1, $gp, $gw ) );
	if ( !defined $child1 ) {
		$minimum_space1->set( $self->_p12($minimum_space1) );
	} else {
		$minimum_space1 = $child1->get_minimum_space($minimum_space1);
		$minimum_space1->set( $self->_p8( $minimum_space1, $gp, $gw ) );
	}
	if ( defined $child2 ) {
		my $minimum_space2 = $available_space->clone();
		$minimum_space2->set( $self->_p5( $available_space, $gp, $gw ) );
		$minimum_space2 = $child2->get_minimum_space($minimum_space2);
		my $return_space = $minimum_space2->clone();
		$return_space->set( $self->_p10($minimum_space1) );
		$return_space->set( $self->_p11( $minimum_space1, $minimum_space2 ) );
		$return_space->set( $self->_p13( $minimum_space1, $minimum_space2 ) );
		return $return_space;
	}
	return $minimum_space1;
}

sub draw {
	my ($self) = @_;
	my $theme = $self->get_theme();

	my $attr = {};
	$self->{_gutter_move_pressed} and $attr->{clicked} = 1;

	my $c  = $self->get_coordinates();
	my $gp = $self->get_gutter_position();

	my $gw = 1;

	$gw > 0 or return;
	for my $i ( 0 .. $gw - 1 ) {
		$self->_p7( $theme, $c, $i, $gp, $attr );
	}
	return;
}


1;
__END__

=head1 SYNOPSIS

    # don't use this widget directly

=head1 DESCRIPTION

A paned widget is a widget containing 2 other widgets. It is used to
stack them horizontally or vertically.

Don't use this widget directly. Please see
L<Curses::Toolkit::Widget::HPaned> and
L<Curses::Toolkit::Widget::VPaned>.

