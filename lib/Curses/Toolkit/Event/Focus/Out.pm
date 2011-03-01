use warnings;
use strict;

package Curses::Toolkit::Event::Focus::Out;

# ABSTRACT: event that is related to out-focus

use parent qw(Curses::Toolkit::Event::Focus);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

Event that is related to out-focus

=head1 CONSTRUCTOR

=head2 new

  input  : none
  output : a Curses::Toolkit::Event::Focus::Out object

=cut

# this event has to be dispatched on a specific widget, so get_matching_widget
# returns void
sub get_matching_widget { return }

1;
