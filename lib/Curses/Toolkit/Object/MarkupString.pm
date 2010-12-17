use warnings;
use strict;

package Curses::Toolkit::Object::MarkupString;

# ABSTRACT: a string that contains markups

use parent qw(Curses::Toolkit::Object);

use Curses;

=head1 DESCRIPTION

Class that manage tied strings to handle style markup transparently

  my $string = Curses::Toolkit::Object::MarkupString->new('hello <span weight="bold">world</span>');

This is an internal Class, you shouldn't use it. 

see L<Curses::Toolkit::Widget::Label> to get the list of supported markups
(like <u>, <b>, <span>).

=cut

# Warning
# The code in this file is just hideous ! :) One day it'll have to be rewritten
# properly I guess...

sub new {
    my ( $class, $markup_string ) = @_;
    length $markup_string or $markup_string = '';
    my $self = bless {
        markup_string   => undef,
        stripped_string => undef,
    }, $class;
    $self->set_markup_text($markup_string);
    return bless $self, $class;
}

sub new_from_computed_string {
    my ( $class, $markup_string, $stripped_string, $attr_struct ) = @_;
    return bless {
        markup_string   => $markup_string,
        stripped_string => $stripped_string,
        attr_struct     => $attr_struct,
    }, $class;
}

sub stripped {
    my ($self) = @_;
    return $self->{stripped_string};
}

sub set_markup_text {
    my ( $self, $text ) = @_;
    $self->{markup_string} = $text;
    $self->_recompute();
    return;
}

sub get_attr_struct {
    my ($self) = @_;
    return $self->{attr_struct};
}

sub stripped_length {
    my ($self) = @_;
    $self->{stripped_string}
        or return 0;
    return length $self->{stripped_string};
}

sub _recompute {
    my ($self) = @_;
    my $markup_string = $self->{markup_string};
    if ( !defined $markup_string || !length $markup_string ) {
        $self->{stripped_string} = '';
        $self->{attr_struct}     = [];
    }

    use HTML::Parser;

    # 	my %text_to_const = ( normal => A_NORMAL,
    # 						  standout => A_STANDOUT,
    # 						  underline => A_UNDERLINE,
    # 						  reverse => A_REVERSE,
    # 						  blink => A_BLINK,
    # 						  dim => A_DIM,
    # 						  bold => A_BOLD );

    # 	my %text_to_color = (black => COLOR_BLACK,
    # 						 red => COLOR_RED,
    # 						 green => COLOR_GREEN,
    # 						 yellow => COLOR_YELLOW,
    # 						 blue => COLOR_BLUE,
    # 						 magenta => COLOR_MAGENTA,
    # 						 cyan => COLOR_CYAN,
    # 						 white => COLOR_WHITE,
    # 						);
    my @struct;

    my @current_attrs;
    my @stack;
    my $parser = HTML::Parser->new(
        api_version => 3,
        start_h     => [
            sub {
                my ( $tagname, $text, $attr ) = @_;
                my %struct = ();
                if ( $tagname eq 'span' ) {
                    push @stack, $tagname;

                    my $weight = $attr->{weight}; #$text_to_const{$attr->{weight} || 'normal'};
                    if ( defined $weight ) {
                        $struct{weight} = $weight;
                    }

                    my $fgcolor = defined $attr->{fgcolor} ? $attr->{fgcolor} : undef; #$text_to_color{$attr->{fgcolor}}
                    my $bgcolor = defined $attr->{bgcolor} ? $attr->{bgcolor} : undef; #$text_to_color{$attr->{bgcolor}}

                    defined $fgcolor
                        and $struct{fgcolor} = $fgcolor;
                    defined $bgcolor
                        and $struct{bgcolor} = $bgcolor;
                    push @current_attrs, \%struct;
                } elsif ( $tagname eq 'b' ) {
                    push @stack, $tagname;
                    push @current_attrs, { weight => 'bold' };
                } elsif ( $tagname eq 'u' ) {
                    push @stack, $tagname;
                    push @current_attrs, { weight => 'underline' };
                } else {
                    push @struct, map { [ $_, _deep_copy(@current_attrs) ] } split( //, $text );
                }
            },
            'tagname, text, attr'
        ],
        end_h => [
            sub {
                my ( $tagname, $text ) = @_;
                if ( @stack && $tagname eq $stack[-1] ) {
                    pop @stack;
                    pop @current_attrs;
                } else {
                    push @struct, map { [ $_, _deep_copy(@current_attrs) ] } split( //, $text );
                }
            },
            'tagname, text'
        ],
        default_h => [
            sub {
                my ($dtext) = @_;
                defined $dtext or $dtext = '';
                push @struct, map { [ $_, _deep_copy(@current_attrs) ] } split( //, $dtext );
            },
            'dtext'
        ],
    );
    $parser->parse($markup_string);
    $parser->eof; # signal end of document

    $self->{stripped_string} = join( '', map { $_->[0] } @struct );
    $self->{attr_struct} = \@struct;

    return;
}

sub _deep_copy {
    return map {
              ref $_ eq 'ARRAY'  ? [ _deep_copy(@$_) ]
            : ref $_ eq 'HASH'   ? { _deep_copy(%$_) }
            : ref $_ eq 'SCALAR' ? \_deep_copy($$_)
            :                      $_;
    } @_;
}

sub substring {
    my ( $self, $start, $width ) = @_;
    my $class               = ref $self;
    my $new_stripped_string = '';
    $start < length( $self->{stripped_string} )
        and $new_stripped_string = substr( $self->{stripped_string}, $start, $width );

    my $r = $class->new_from_computed_string(
        undef,                                                          # markup string
        $new_stripped_string,                                           # stripped string
        [ @{ $self->{attr_struct} }[ $start .. $start + $width - 1 ] ], # attr_struct
    );
    return $r;
}

sub search_replace {
    my ( $self, $pattern, $replace, $limit ) = @_;
    defined $replace or $replace = '';
    my $string = $self->{stripped_string};
    my $count  = 0;
    while ( $string =~ /$pattern/g ) {
        my $start = length($`);
        my $width = length($&);

        $self->{markup_string} = undef;
        substr( $self->{stripped_string}, $start, $width, $replace );

        my @repl_attr = @{ ( $start ? $self->{attr_struct}->[ $start - 1 ] : [] ) };
        shift @repl_attr;
        splice( @{ $self->{attr_struct} }, $start, $width, map { [ $_, @repl_attr ] } split( //, $replace ) );

        defined $limit or next;
        ++$count >= $limit and last;
    }
    return;

}

sub split_string {
    my ( $self, $pattern, $limit ) = @_;
    my $class   = ref $self;
    my $string  = $self->{stripped_string};
    my $start   = 0;
    my $count   = 0;
    my @results = ();
    while ( $string =~ /$pattern/g ) {
        my ($prematch, $match, $postmatch) = ($`, $&, $');
        my $end = $start + length($prematch) - 1;
        push @results, $class->new_from_computed_string(
            undef,                                           # markup string
            $prematch,                                       # stripped string
            [ @{ $self->{attr_struct} }[ $start .. $end ] ], # attr_struct
        );
        $start  = $end + 1 + length($match);
        $string = $postmatch;
        defined $limit or next;
        ++$count >= $limit and last;
    }
    length $string
        and push @results,
        $class->new_from_computed_string(
        undef,
        $string,
        [ @{ $self->{attr_struct} }[ $start .. $start + length($string) - 1 ] ]
        );
    return @results;
}

sub append {
    my ( $self, $append ) = @_;
    if ( ref $append eq ref $self ) {
        $self->{stripped_string} .= $append->{stripped_string};
        defined $self->{markup_string} && defined $append->{markup_string}
            and $self->{markup_string} .= $append->{markup_string};
        $self->{attr_struct} = [ @{ $self->{attr_struct} }, @{ $append->{attr_struct} } ];
        return;
    }
    $self->{stripped_string} .= $append;
    $self->{markup_string} = undef;

    my $i = scalar @{ $self->{attr_struct} };
    my @repl_attr = @{ $i ? $self->{attr_struct}->[-1] : [] };

    shift @repl_attr;
    push( @{ $self->{attr_struct} }, map { [ $_, @repl_attr ] } split( //, $append ) );
    return;
}

sub chomp_string {
    my ($self) = @_;
    my $original_len = $self->stripped_length();
    chomp $self->{stripped_string};
    my $new_len = $self->stripped_length();
    if ( $original_len != $new_len ) {
        $self->{markup_string} = undef;
        splice( @{ $self->{attr_struct} }, $new_len, $original_len - $new_len );
    }
    return $original_len - $new_len;
}

1;

