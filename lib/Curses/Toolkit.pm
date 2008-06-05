package Curses::Toolkit;

use warnings;
use strict;

=head1 NAME

Curses::Toolkit - a modern Curses toolkit

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module tries to be a modern curses toolkit, based on the Curses module, to
build "graphical" console user interfaces easily.

  use Curses::Toolkit;

  my $root = Curses::Toolkit->init_root_window();
  my $window = Curses::Toolkit::Window->new();
  $root->add($window);
  ...
  $root->render

=head1 CLASS METHODS

=head2 init_root_window

Initialize the Curses environment, and return an object representing it. This
is not really a constructor, because you can't have more than one
Curses::Toolkit object for one Curses environment.

  input : none
#clear_background : optional, boolean, default 1 : if true, clears background
  output : a Curses::Toolkit object

=cut

sub init_root_window {
    my $class = shift;
    
    use Params::Validate qw(:all);
#    my %params = validate(@_, { clear_background => { type => BOOLEAN,
#                                                      default => 1
#                                                    },
#                              }
#                         );

    # get the Curses handler
    use Curses;
    my $curses_handler = Curses->new();
    
    # curses basic init
#    Curses::noecho();
#    Curses::cbreak();
#    curs_set(0);
#    Curses::leaveok(1);

#$curses_handler->erase();

    # erase the window if asked.
#    print STDERR Dumper($params{clear_background}); use Data::Dumper;
#    $params{clear_background} and $curses_handler->erase();
    
    my $self = bless { curses_handler => $curses_handler
                     }, $class;
    return $self;
}

DESTROY {
    my ($obj) = @_;
    # ending Curses
    Curses::endwin;
}

=head2 

=head1 AUTHOR

Damien "dams" Krotkine, C<< <dams at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-curses-toolkit at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Curses-Toolkit>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Curses::Toolkit

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Curses-Toolkit>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Curses-Toolkit>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Curses-Toolkit>

=item * Search CPAN

L<http://search.cpan.org/dist/Curses-Toolkit>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Damien "dams" Krotkine, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Curses::Toolkit
