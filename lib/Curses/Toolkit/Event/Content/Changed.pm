use warnings;
use strict;

package Curses::Toolkit::Event::Content::Changed;

# ABSTRACT: event that is related to content change

use parent qw(Curses::Toolkit::Event::Content);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

Event that is related to content change

=head1 CONSTRUCTOR

=head2 new

  input  : none
  output : a Curses::Toolkit::Event::Content::Changed

=cut

# this event has to be dispatched on a specific widget, so get_matching_widget
# returns void
sub get_matching_widget { return }

1;
