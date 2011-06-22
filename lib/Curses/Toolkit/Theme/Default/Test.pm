use warnings;
use strict;

package Curses::Toolkit::Theme::Default::Test;

# ABSTRACT: widget test theme

use parent qw(Curses::Toolkit::Theme::Default);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);
use Curses;


=head1 DESCRIPTION

This theme is used for testing : it doesn't mess too much with the terminal,
and it provides the output as string, that can be used for checking test
results.

=head1 CONSTRUCTOR

=head2 new

the coderef will be called with 3 arguments : $x, $y, and the data to be outputed.

  input : a Curses::Toolkit::Widget
          a CoderRef, called for each line to be output
  output : a Curses::Toolkit::Theme::Default::Test object

=cut

sub new {
    my $class = shift;
    my $widget = shift;
    my $output_writer = sub { print "@_\n"; };
#    my ($widget, $output_writer) = validate_pos( @_, { isa => 'Curses::Toolkit::Widget' }, { type => CODEREF } );
    $output_writer ||= sub { };
    my $self = $class->SUPER::new($widget);
    $self->{output_writer} = $output_writer;
    $self->{curses_mockup} = Curses::Toolkit::Theme::Default::Test::CursesMockup->new( { output_writer => $output_writer } );

    return $self;
}

# override curses handler method

sub _get_curses_handler {
    my ($self) = @_;
    return $self->{curses_mockup};
}


sub default_fgcolor { 'white' }
sub default_bgcolor { 'black' }

sub ULCORNER { '+'; }
sub LLCORNER { '+'; }
sub URCORNER { '+'; }
sub LRCORNER { '+'; }
sub HLINE    { '-'; }
sub VLINE    { '|'; }


# the values of this theme
sub HLINE_NORMAL  {  }
sub HLINE_FOCUSED {  }
sub HLINE_CLICKED {  }

sub VLINE_NORMAL  {  }
sub VLINE_FOCUSED {  }
sub VLINE_CLICKED {  }

sub CORNER_NORMAL  {  }
sub CORNER_FOCUSED {  }
sub CORNER_CLICKED {  }

sub STRING_NORMAL  { }
sub STRING_FOCUSED { }
sub STRING_CLICKED { }

sub VSTRING_NORMAL  { }
sub VSTRING_FOCUSED { }
sub VSTRING_CLICKED { }

sub TITLE_NORMAL  { }
sub TITLE_FOCUSED { }
sub TITLE_CLICKED { }

sub RESIZE_NORMAL  { }
sub RESIZE_FOCUSED { }
sub RESIZE_CLICKED { }

sub BLANK_NORMAL  { }
sub BLANK_FOCUSED { }
sub BLANK_CLICKED { }


package Curses::Toolkit::Theme::Default::Test::CursesMockup;

sub new { bless { %{$_[1]} }, $_[0] }
sub attrset { }
sub attron { }
sub attroff { }

sub hline  { $_[0]->{output_writer}->($_[2], $_[1], $_[3] x $_[4]) }
sub vline  { $_[0]->{output_writer}->($_[2], $_, $_[3]) foreach ( $_[1] .. $_[1]+$_[4]-1) }
sub addch  { $_[0]->{output_writer}->($_[2], $_[1], $_[3])  }
sub addstr { $_[0]->{output_writer}->($_[2], $_[1], $_[3])  }

1;
