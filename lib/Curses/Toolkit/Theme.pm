package Curses::Toolkit::Theme;

use warnings;
use strict;

use parent qw(Curses::Toolkit);

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

1;
