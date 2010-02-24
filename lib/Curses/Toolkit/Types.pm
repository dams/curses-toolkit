use strict;
use warnings;

package Curses::Toolkit::Types;

# ABSTRACT: various types used within the dist

use Moose::Util::TypeConstraints;

enum PROGRESS_BAR_LABEL => qw{ none value percent };

1;
__END__


=head1 DESCRIPTION

This module implements the specific types used by the distribution, and
exports them (exporting is done directly by
L<Moose::Util::TypeConstraints>.

Current types defined:

=over 4

=item * PROGRESS_BAR_LABEL - a simple enumeration, allowing only
C<none>, C<value> or C<percent>.

=back
