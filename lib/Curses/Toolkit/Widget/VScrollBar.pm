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

                    $event->{button} eq 'button1' or return 0;
                    $self->{_pressed} && $event->{type} eq 'released'
                      and return 1;
                    $self->{_pressed}
                      and return 0;
                    $event->{type} eq 'pressed'
                      or return 0;
                    my $scroll_delta = 1;
                    my $c  = $event->{coordinates};
                    my $wc = $self->get_coordinates();
                    $c->get_y1() == $wc->get_y1() || $c->get_y1() == $wc->get_y2() - 1
                      or return 0;
                    $c->get_y1() == $wc->get_y1()
                      or $scroll_delta = -$scroll_delta;
                    $event->custom_data->{scroll_delta} = $scroll_delta;
                    return 1;
                },
            },
            code => sub {
                my ( $event, $vscrollbar ) = @_;

                if ($self->{_pressed}) {
                    # means we released it
                    $vscrollbar->unset_modal();
                    $self->{_pressed} = 0;
                    $self->{_scrolling}{enabled} = 0;
                    return;
                }

                # means we pressed it
                $vscrollbar->set_modal();
                my $scroll_area = $vscrollbar->get_scroll_area;
                defined $scroll_area
                  or return;

                my $scroll_delta = $event->custom_data->{scroll_delta};
                $scroll_area->scroll(y => $scroll_delta);

                $self->{_pressed} = 1;
                $self->{_scrolling}{enabled} = 1;
                $self->{_scrolling}{scroll_delta} = $scroll_delta;
                $self->_start_scrolling_animation();
                return;
            },
        )
    );

    $self->add_event_listener(
        Curses::Toolkit::EventListener->new(
            accepted_events => {
                'Curses::Toolkit::Event::Mouse::Click' => sub {
                    my ($event) = @_;

                    $event->{button} eq 'button1' or return 0;

                    my $scroll_delta = 0;
                    $event->{type}   eq 'clicked'
                      and $scroll_delta = 1;
                    $event->{type}   eq 'double_clicked'
                      and $scroll_delta = 2;
                    $event->{type}   eq 'triple_clicked'
                      and $scroll_delta = 3;
                    $scroll_delta or return 0;

                    my $c  = $event->{coordinates};
                    my $wc = $self->get_coordinates();
                    $c->get_y1() == $wc->get_y1() || $c->get_y1() == $wc->get_y2() - 1
                      or return 0;
                    $c->get_y1() == $wc->get_y1()
                      or $scroll_delta = -$scroll_delta;

                    $event->custom_data->{scroll_delta} = $scroll_delta;
                    return 1;
                },
            },
            code => sub {
                my ( $event, $vscrollbar ) = @_;

                my $scroll_area = $vscrollbar->get_scroll_area;
                defined $scroll_area
                  or return;

                my $scroll_delta = $event->custom_data->{scroll_delta};
                $scroll_area->scroll(y => $scroll_delta);
                return;
            },
        )
    );

    return $self;
}

sub _start_scrolling_animation {
    my ($self) = @_;

    my $root_window = $self->get_root_window();
    my $delay = 1/4;

    my $delay_sub;
    $delay_sub = sub {

        $self->{_scrolling}{enabled}
          or return;

        my $scroll_area = $self->get_scroll_area;
        defined $scroll_area
          or return;

        my $scroll_delta = $self->{_scrolling}{scroll_delta};
        $scroll_area->scroll(y => $scroll_delta);

        my $root_window = $self->get_root_window();
        $root_window->add_delay( $delay, $delay_sub );
    };

    $root_window->add_delay( $delay, $delay_sub );
    return;
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
        $theme->draw_resize( $c->get_x1(), $c->get_y1()+1+$y,);
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
