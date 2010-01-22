use warnings;
use strict;

package Curses::Toolkit::Signal::Focused::In;

use parent qw(Curses::Toolkit::Signal::Focused);

use Params::Validate qw(:all);

=head1 NAME

Curses::Toolkit::Signal::Focused::In

=head1 DESCRIPTION

Signal triggered when a widget is focused in

=head1 CONSTRUCTOR

=cut

sub generate_listener {
	my $class = shift;
	my %args = validate( @_,
						 { widget => { isa => 'Curses::Toolkit::Widget' },
						   code_ref => { type => CODEREF },
						   arguments => { type => ARRAYREF },
						 },
					   );
	my $widget = $args{widget};
	my $code_ref = $args{code_ref};
	my @arguments = @{$args{arguments}};

	return Curses::Toolkit::EventListener->new(
		accepted_events => {
			'Curses::Toolkit::Event::Focus::In' => sub { 
				my ($event) = @_;
				return 1;
			},
		},
		code => sub {
			$code_ref->(@_, @arguments);
		},
	);
}

1;
