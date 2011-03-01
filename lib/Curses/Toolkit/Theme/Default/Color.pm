use warnings;
use strict;

package Curses::Toolkit::Theme::Default::Color;

# ABSTRACT: base class for default coloured widgets themes

use parent qw(Curses::Toolkit::Theme::Default);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);
use Curses;

=head1 DESCRIPTION

Base class for default coloured widgets themes

=head1 CONSTRUCTOR

None, this is an abstract class

=cut

1;
