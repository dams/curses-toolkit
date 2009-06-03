package Curses::Toolkit::Theme;

use warnings;
use strict;

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Theme - base class for widgets themes

=head1 DESCRIPTION

Base class for widgets themes

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

sub new {
    my $class = shift;
	my ($widget) = validate_pos(@_, { isa => 'Curses::Toolkit::Widget' });
    $class eq __PACKAGE__ and die "abstract class";
	return bless { widget => $widget }, $class;
}

sub get_widget {
	my ($self) = @_;
	return $self->{widget};
}

sub curses {
	my ($self) = @_;
	$self->_get_curses_handler()->attrset(0);
	my $caller = (caller(1))[3];
	my $type = uc( (split('_', $caller))[1] );
	$self->_compute_attributes($type);
	return $self->_get_curses_handler();
}

# gets the curses handler of the associated widget
#
#  input  : none
#  output : a Curses object
sub _get_curses_handler {
	my ($self) = @_;
	return $self->get_widget()->_get_curses_handler();
}

sub _compute_attributes {
	my ($self, $type) = @_;
	my $method = $type . '_NORMAL';
	$self->$method();
# 	if ( ! $self->get_widget()->is_visible() ) {
# 		$method = $type . '_INVISIBLE';
# 	}
	if ( $self->get_widget()->isa('Curses::Toolkit::Role::Focusable') &&
		 $self->get_widget()->is_focused() ) {
		$method = $type . '_FOCUSED';
		$self->$method();
	}
	return;
}

sub _attron {
	my $self = shift;
	$self->_get_curses_handler()->attron(@_);
}

sub _attroff {
	my $self = shift;
	$self->_get_curses_handler()->attroff(@_);
}

sub _attrset {
	my $self = shift;
	$self->_get_curses_handler()->attrset(@_);
}

1;
