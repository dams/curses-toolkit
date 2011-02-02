#!/usr/bin/perl

use HTML::Parser;

# subtract of pango  :
# weight : One of 'normal', 'bold'
# fgcolor :
# bgcolor :
# underline

my @stack;

# Create parser object
$p = HTML::Parser->new(
	api_version => 3,
	start_h     => [ \&start, "tagname, dtext, attr, text" ],
	end_h       => [ \&end, "tagname,dtext, attr" ],
	default_h   => [ \&default, "dtext" ],
);

# Parse document text chunk by chunk
$p->parse('This is <h1 a=b>a</h1><span bold,italic> good <span underline="true">example</span>, another </span>chunk');
$p->eof; # signal end of document
print "\n";

sub start {
	my ( $tagname, $dtext, $attr, $text ) = @_;
	if ( $tagname eq 'span' ) {
		print "[SPAN]";
		print Dumper($attr); use Data::Dumper;
	} elsif ( $tagname eq 'b' ) {
		print "[B]";
	} elsif ( $tagname eq 'u' ) {
		print "[U]";
	} else {
		print "$text";
	}
}

sub end {
	my ( $tagname, $dtext, $attr ) = @_;
	if ( $tagname eq 'span' ) {
		print "[span]";
	} elsif ( $tagname eq 'b' ) {
		print "[b]";
	} elsif ( $tagname eq 'u' ) {
		print "[u]";
	} else {
		my ($dtext) = @_;
		print "$text";
	}
}

use Curses;
my $a;
$a = A_NORMAL;
print "[$a]\n";
$a = A_STANDOUT;
print "[$a]\n";
$a = A_UNDERLINE;
print "[$a]\n";
$a = A_REVERSE;
print "[$a]\n";
$a = A_BLINK;
print "[$a]\n";
$a = A_DIM;
print "[$a]\n";
$a = A_BOLD;
print "[$a]\n";
$a = A_ALTCHARSET;


sub default {
	my ($dtext) = @_;
	print "$dtext";
}

