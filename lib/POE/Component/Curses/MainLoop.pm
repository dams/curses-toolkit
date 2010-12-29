use warnings;
use strict;

package POE::Component::Curses::MainLoop;

# ABSTRACT: <FIXME to be filled>

use Moose 0.92;
use MooseX::FollowPBP;
use POE;
use Params::Validate qw(:all);

use Curses::Toolkit;

=head1 SYNOPSIS

This module is not for you !

You should not use this module directly. It's used by L<POE::Component::Curses>
as a MainLoop interface to L<Curses::Toolkit>

Please look at L<POE::Component::Curses>. Thanks !

=cut

# constructor arguments
has session_name => ( is => 'rw', isa => 'Str' );
has args => ( is => 'ro', isa => 'HashRef', default => sub { {} } );

has toolkit_root  => ( is => 'ro', isa => 'Curses::Toolkit', lazy_build => 1, init_arg => undef );
has redraw_needed => ( is => 'rw', isa => 'Bool',            default    => 0, init_arg => undef );

sub _build_toolkit_root {
    my $self         = shift;
    my $toolkit_root = Curses::Toolkit->init_root_window( %{ $self->get_args } );
    $toolkit_root->set_mainloop($self);
    return $toolkit_root;
}



#### Now implement the Mainloop API ####

## Methods called by the Curses::Toolkit objects ##
## They usually returns $self, or a return value

# Curses::Toolkit requires a redraw to happen at some time
sub needs_redraw {
    my ($self) = @_;

    # if redraw is already stacked, just quit
    $self->get_redraw_needed
        and return;
    $self->set_redraw_needed(1);
    $poe_kernel->post( $self->get_session_name, 'redraw' );
    return $self;
}

# Curses::Toolkit asks a code snipets to be executed after a delay
sub add_delay {
    my $self    = shift;
    my $seconds = shift;
    my $code    = shift;
    $poe_kernel->call( $self->get_session_name, 'add_delay_handler', $seconds, $code, @_ );
    return;
}

# Curses::Toolkit needs an event to be stacked for dispatch
sub stack_event {
    my $self = shift;
    $poe_kernel->post( $self->get_session_name, 'stack_event', @_ );
    return;
}

## Methods called by the POE Component session ##
## They usually return nothing

# POE::Component::Curses asked to rebuild all coordinates
sub event_rebuild_all {
    my ($self) = @_;
    $self->get_toolkit_root->_rebuild_all();
    return;
}

# POE::Component::Curses ordered a redraw
sub event_redraw {
    my ($self) = @_;

    # unset this early so that redraw requests that may appear in the meantime will
    # be granted
    $self->set_redraw_needed(0);

    $self->get_toolkit_root->render();
    $self->get_toolkit_root->display();
    return;
}

# POE::Component::Curses informed on a window resize event
sub event_resize {
    my ($self) = @_;

    use Curses::Toolkit::Event::Shape;
    my $event = Curses::Toolkit::Event::Shape->new(
        type        => 'change',
        root_window => $self->get_toolkit_root
    );
    $self->get_toolkit_root->dispatch_event($event);
    return;
}

# POE::Component::Curses informed on a keyboard event
sub event_key {
    my $self = shift;

    my %params = validate(
        @_,
        {   type => 1,
            key  => 1,
        }
    );

    $params{type} eq 'stroke'
        or return;

    use Curses::Toolkit::Event::Key;

    #		print STDERR " -- Mainloop stroke : [$params{key}] \n";
    my $event = Curses::Toolkit::Event::Key->new(
        type        => 'stroke',
        params      => { key => $params{key} },
        root_window => $self->get_toolkit_root,
    );
    $self->get_toolkit_root->dispatch_event($event);
}

# POE::Component::Curses informed on a mouse event
sub event_mouse {
    my $self = shift;

    my %params = validate(
        @_,
        {   type   => 1,
            type2  => 1,
            button => 1,
            x      => 1,
            y      => 1,
            z      => 1,
        }
    );

    $params{type} eq 'click'
        or return;

    use Curses::Toolkit::Event::Mouse::Click;
    $params{type} = delete $params{type2};
    use Curses::Toolkit::Object::Coordinates;
    $params{coordinates} = Curses::Toolkit::Object::Coordinates->new(
        x1 => $params{x},
        x2 => $params{x},
        y1 => $params{y},
        y2 => $params{y},
    );
    delete @params{qw(x y z)};
    my $event = Curses::Toolkit::Event::Mouse::Click->new( %params, root_window => $self->get_toolkit_root );

    $self->get_toolkit_root->dispatch_event($event);
}

# POE::Component::Curses informed on an event
sub event_generic {
    my $self = shift;
    $self->get_toolkit_root->dispatch_event(@_);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
