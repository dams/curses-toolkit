use warnings;
use strict;

package Curses::Toolkit::Widget::VScrollBar;

# ABSTRACT: a vertical scrollbar widget

use parent qw(Curses::Toolkit::Widget::ScrollBar);

use Params::Validate qw(SCALAR ARRAYREF HASHREF CODEREF GLOB GLOBREF SCALARREF HANDLE BOOLEAN UNDEF validate validate_pos);

=head1 DESCRIPTION

This widget is just the vertical scrollbar. Usually you will want to use 
Curses::Toolkit::Widget::ScrollArea. It inherits from Curses::Toolkit::Widget::ScrollBar.

=head1 CONSTRUCTOR

=head2 new

  input : none
  output : a Curses::Toolkit::Widget::VScrollBar object

=cut

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->{visibility_mode} = 'auto';
    return $self;
}

sub draw {
    my ($self) = @_;
    my $theme = $self->get_theme();
    my $c = $self->get_coordinates();

    print STDERR "\n\n----------------\n\n";
    print STDERR Dumper($self->get_fill); use Data::Dumper;
    my $fill = $self->get_fill();
    my $fill_height = $fill * ($c->height()-2);
    $theme->draw_string( $c->get_x1(), $c->get_y1(), '^');
    foreach my $y (0..$fill_height) {
        $theme->draw_string( $c->get_x1(), $c->get_y1()+1+$y, '#');
    }
    $theme->draw_vline( $c->get_x1(), $c->get_y1()+1+$fill_height+1, $c->height()-2-$fill_height);
    $theme->draw_string( $c->get_x1(), $c->get_y2()-1, 'v');
    return;
}


1;
