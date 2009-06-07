package Curses::Toolkit::Role::Focusable;

use warnings;
use strict;

use parent qw(Curses::Toolkit::Role);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Role::Focusable - This role implements the fact that a widget can have focus

=head1 DESCRIPTION

If a widget inherits of this role, it can be focused (except if its sensitivity
is set to false). This will disappear once I use Moose and don't need
multiple inheritance anymore.

This role can be merged in anything that is a Curses::Toolkit::Widget

=head1 CONSTRUCTOR

None, this is a role, so it has no constructor

=cut

sub new {
    my ($class) = shift;
    # TODO : use Exception;
    # $class eq __PACKAGE__ and;
	die "role class, has no constructor";
}

=head2 is_focusable

Returns 1, except if the widget has its sensitivity set to false

=cut

sub is_focusable {
    my ($self) = @_;
	return($self->is_sensitive() ? 1 : 0);
}

=head2 set_focus

  $widget->set_focus(1); # set focus to this widget
  $widget->set_focus(0); # remove focus from this widget

Sets the focus on/off on the widget.

  input : a boolean
  output : the widget

=cut

sub set_focus {
	my $self = shift;
	my ($focus) = validate_pos( @_, { type => BOOLEAN } );

	if ($self->is_focusable()) {
		$self->set_property(basic => 'focused', $focus ? 1 : 0);
		if ($focus) {
			if ($self->can('get_window')) {
				my $window = $self->get_window();
				if (defined $window) {
					$window->set_focused_widget($self);
				}
			}
		}
		$self->needs_redraw();
	}
	return $self;
}

=head2 get_next_focused_widget

  my $next_focused_widget = $widget->get_next_focused_widget();

Returns the widget next in the focus chain

  input : none
  output : the enxt focused widget

=cut

sub get_next_focused_widget {
	my ($self) = @_;

	my $next_widget;
	# look down and right
	$next_widget = $self->_recursive_f1($self, 1);
	defined $next_widget and return $next_widget;

	# nothing down and right ? look up and right
	$next_widget = $self->_recursive_f2($self);
	defined $next_widget and return $next_widget;

	# still nothing ? Start from top and look down
	my $window = $self->get_window();
	defined $window or return;
	return $self->_recursive_f1($window);
}

sub _recursive_f1 {
	my ($self, $widget, $avoid_me) = @_;
	# Is the widget focusable ?
	unless ($avoid_me) {
		$widget->isa('Curses::Toolkit::Role::Focusable') && $widget->is_focusable()
		  and return $widget;
	}

	# does the widget have any children ?
	if ($widget->isa('Curses::Toolkit::Widget::Container')) {		
		my @children = $widget->get_children();
		if (@children) {
			my $next_widget = $self->_recursive_f1($children[0]);
			defined $next_widget and return $next_widget;
		}
	}
	# does the widget have a brother ?
	my $brother_widget = $widget->_get_brother();
	defined $brother_widget or return;

	return $self->_recursive_f1($brother_widget);
}

sub _recursive_f2 {
	my ($self, $widget) = @_;
	# get parent
	my $parent_widget = $widget->get_parent();
	defined $parent_widget or return;

	# is the parent focusable ?
	$parent_widget->isa('Curses::Toolkit::Role::Focusable') && $parent_widget->is_focusable()
	  and return $parent_widget;

	# if not, apply f1 on its potential brother
	my $brother_widget = $parent_widget->_get_brother();
	if (defined $brother_widget) {
		my $next_widget = $self->_recursive_f1($brother_widget);
		defined $next_widget and return $next_widget;
	}

	# still nothing ? call f2
	my $next_widget = $self->_recursive_f2($parent_widget);
	defined $next_widget and return $next_widget;

	return;
}

=head2 is_focused

Retrieves the focus setting of the widget.

  input : none
  output : true if the widget is focused, or false if not

=cut

sub is_focused {
	my ($self) = @_;
	return $self->get_property(basic => 'focused');
}

1;


