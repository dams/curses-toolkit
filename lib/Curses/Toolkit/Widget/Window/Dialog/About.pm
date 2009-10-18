use warnings;
use strict;

package Curses::Toolkit::Widget::Window::Dialog::About;
# ABSTRACT: an about dialog window

use parent qw(Curses::Toolkit::Widget::Window::Dialog);


=head1 DESCRIPTION

This about window offers a simple way to display information about a program
like its logo, name, copyright, website and license. It is also possible to
give credits to the authors, documenters, translators and artists who have
worked on the program. An about dialog is typically opened when the user
selects the About option from the Help menu. All parts of the dialog are
optional.

=cut

1;