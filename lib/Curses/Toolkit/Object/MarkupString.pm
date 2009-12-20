use warnings;
use strict;

package Curses::Toolkit::Object::MarkupString;
# ABSTRACT: a string that contains markups

use parent qw(Curses::Toolkit::Object);

use Curses;

=head1 DESCRIPTION

Class that manage tied strings to handle style markup transparently

  my $string = Curses::Toolkit::Object::MarkupString->new('hello <span weight="bold">world</span>');

=head1 CONSTRUCTOR

=head1 new

=cut

sub new {
	my ($class, $markup_string) = @_;
	length $markup_string or $markup_string = '';
	my $self = bless { markup_string => undef,
					   stripped_string => undef,
					 }, $class;
	$self->set_markup_text($markup_string);
	return bless $self, $class;
}

sub stripped {
	my ($self) = @_;
	return $self->{stripped_string};
}

sub set_markup_text {
	my ($self, $text) = @_;
	$self->{markup_string} = $text;
	$self->_recompute();
	return;
}

sub get_attr_struct {
	my ($self) = @_;
	return $self->{attr_struct};
}

sub substring {
	my ($self, $start, $width) = @_;
	$self->{markup_string} = undef;
	$self->{stripped_string} = substr($self->{stripped_string}, $start, $width);
	@{$self->{attr_struct}} = splice(@{$self->{attr_struct}}, $start, $width);
	return;
}

sub stripped_length {
	my ($self) = @_;
	return length $self->{stripped_string};
}

sub _recompute {
	my ($self) = @_;
	my $markup_string = $self->{markup_string};
	if (!defined $markup_string || ! length $markup_string) {
		$self->{stripped_string} = '';
		$self->{attr_struct} = [];
	}

	use HTML::Parser;

	my %text_to_const = ( normal => A_NORMAL,
						  standout => A_STANDOUT,
						  underline => A_UNDERLINE,
						  reverse => A_REVERSE,
						  blink => A_BLINK,
						  dim => A_DIM,
						  bold => A_BOLD );

	my @struct;

	my @current_attrs;
	my @stack;
	my $parser = HTML::Parser->new(
		api_version => 3,
		start_h   => [ sub {
						   my ($tagname, $text, $attr) = @_;
						   if      ($tagname eq 'span') {
							   my $weight = $text_to_const{$attr->{weight}};
							   defined $weight
								 and push @stack, { tagname => $tagname,
													weight => $weight,
												  };
							   push @current_attrs, $weight;
						   } elsif ($tagname eq 'b') {
							   push @stack, { tagname => $tagname,
											  weight => A_BOLD,
											};
							   push @current_attrs, A_BOLD;
						   } elsif ($tagname eq 'u') {
							   push @stack, { tagname => $tagname,
											  weight => A_UNDERLINE,
											};
							   push @current_attrs, A_UNDERLINE;
						   } else {
							   push @struct, map { [ $_, @current_attrs ] } split(//, $text);
						   }
					   },
					   'tagname, text, attr' ],
		end_h     => [ sub {
						   my ($tagname, $text) = @_;
						   if (@stack && $tagname eq $stack[-1]{tagname}) {
							   pop @stack;
							   pop @current_attrs;
						   } else {
							   push @struct, map { [ $_, @current_attrs ] } split(//, $text);
						   }
					   },   'tagname, text' ],
		default_h => [ sub {
						   my ($dtext) = @_;
						   defined $dtext or $dtext = '';
						   push @struct, map { [ $_, @current_attrs ] } split(//, $dtext);
					   },   'dtext' ],
	);
	$parser->parse($markup_string);
	$parser->eof;                 # signal end of document

	$self->{stripped_string} = join('', map { $_->[0] } @struct);
	$self->{attr_struct} = \@struct;
	return;
}

1;
