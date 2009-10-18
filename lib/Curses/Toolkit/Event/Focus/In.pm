use warnings;
use strict;

package Curses::Toolkit::Event::Focus::In;

use parent qw(Curses::Toolkit::Event::Focus);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Event::Focus::In - event that is related to in-focus

=head1 DESCRIPTION

Event that is related to in-focus

=head1 CONSTRUCTOR

=head2 new

  input : root_window : Curses::Toolkit : the root window object

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new();
	my %args = validate( @_,
						 { 
						   root_window => { isa => 'Curses::Toolkit' },
						 }
					   );
	$self = bless(\%args, $class);
	return $self;
}

# this event has to be dispatched on a specific widget, so get_matching_widget
# returns void
sub get_matching_widget { return }

1;
