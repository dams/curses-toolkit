package Curses::Toolkit::Widget::Pane;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Widget::Container);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Widget::Pane - generic pane widget

=head1 DESCRIPTION

Don't use this widget. Please see L<Curses::Toolkit::Widget::HPane> and L<Curses::Toolkit::Widget::VPane>

=cut

sub new {
    my $class = shift;
    # TODO : use Exception;
    $class eq __PACKAGE__ and die "This is an abstract class, please see Curses::Toolkit::Widget::HPane and Curses::Toolkit::Widget::VPane";
	my $self =  $class->SUPER::new(@_);

	# default position
	$self->set_gutter_position(0);

	# listen to the Mouse for moving the gutter
	$self->add_event_listener(
		Curses::Toolkit::EventListener->new(
			accepted_event_class => 'Curses::Toolkit::Event::Mouse::Click',
			conditional_code => sub { 
				my ($event) = @_;
				$event->{button} eq 'button1' or return 0;
				$self->{_gutter_move_pressed} && $event->{type} eq 'released'
				  and return 1;
				my $ec = $event->{coordinates};
				my $wc = $self->get_coordinates();
				my $gp = $self->get_gutter_position();
				#	my $gw = $self->get_theme_property('gutter_width');
				my $gw = 1;
				! $self->{_gutter_move_pressed}
				&& $event->{type} eq 'pressed'
				&& $self->_mouse_conditional_code($ec, $wc)
				  and return 1;
				return 0;
			},
			code => sub {
				my ($event, $widget) = @_;

				if ($self->{_gutter_move_pressed}) {
					# means we released it
					$self->unset_modal();
					my $c = $event->{coordinates};
					my $wc = $self->get_coordinates();
					$self->set_gutter_position($c->x1() - $wc->x1() );
					$self->_rebuild_children_coordinates();
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

1;
