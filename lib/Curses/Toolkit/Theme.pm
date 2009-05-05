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

# gets the curses handler of the associated widget
#
#  input  : none
#  output : a Curses object
sub _get_curses_handler {
	my ($self) = @_;
	return $self->{widget}->_get_curses_handler();
}

1;
