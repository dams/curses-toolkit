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
	return $class->SUPER::new(@_);
}

1;
