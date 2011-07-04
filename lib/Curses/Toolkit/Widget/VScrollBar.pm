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
    $self->{scroll_area} = undef;

    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Mouse::Click' => sub {
                    my ($event) = @_;
                    $event->{type}   eq 'clicked' or return 0;
                    $event->{button} eq 'button1' or return 0;

                    my $c  = $event->{coordinates};
                    my $wc = $self->get_coordinates();
                    $c->get_y1() == $wc->get_y1() || $c->get_y1() == $wc->get_y2()
                      or return 0;
                    return 1;
                },
            },
            code => sub {
                my ( $event, $vscrollbar ) = @_;

                my $scroll_area = $vscrollbar->get_scroll_area;
                defined $scroll_area
                  or return;

                my $c  = $event->{coordinates};
                my $wc = $self->get_coordinates();
                $c->get_y1() == $wc->get_y1()
                  and $scroll_area->scroll(y => -1);
                $c->get_y1() == $wc->get_y2()
                  and $scroll_area->scroll(y => 1);
                return;
            },
        )
    );

    return $self;
}

# attach the scrollbar to a given scroll area
sub set_scroll_area {
    my ($self, $scroll_area) = @_;
    $self->{scroll_area} = $scroll_area;
    return $self;
}

sub get_scroll_area {
    my ($self) = @_;
    return $self->{scroll_area};
}

sub draw {
    my ($self) = @_;
    my $theme = $self->get_theme();
    my $c = $self->get_coordinates();

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

sub possible_signals {
    my ($self) = @_;
    return (
        $self->SUPER::possible_signals(),
        scrolled_up => 'Curses::Toolkit::Signal::Scrolled::Up',
        scrolled_down => 'Curses::Toolkit::Signal::Scrolled::Down',
    );
}

1;
