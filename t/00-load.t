#!perl -Tw

use Test::More;

BEGIN {
	use_ok( 'Curses::Toolkit' );
}

my @modules = qw(
    Curses
    Curses::Toolkit
);

plan tests => scalar(@modules);

# try to load all modules
foreach my $module (@modules) {
    use_ok( $module );
}

diag( "Testing Curses::Toolkit $Curses::Toolkit::VERSION, Perl $], $^X" );
