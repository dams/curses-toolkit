use strict;
use warnings;

package Curses::Toolkit::Types;

# ABSTRACT: various types used within the dist

sub PROGRESS_BAR_LABEL {
    return({ map { $_ => 1 } (qw(none value percent)) });
}

1;
__END__


=head1 DESCRIPTION

This module implements the specific types used by the distribution

Current types defined:

=over

=item * PROGRESS_BAR_LABEL - C<none>, C<value> or C<percent>.

=back
