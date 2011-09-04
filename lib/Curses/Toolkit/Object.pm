use warnings;
use strict;

package Curses::Toolkit::Object;
# ABSTRACT: base class for objects

sub new {
    my $class = shift;
    $class eq __PACKAGE__ and die "abstract class";
    return bless { }, $class;
}

1;
__END__

=head1 DESCRIPTION

Base class for objects. This class cannot be instanciated.
