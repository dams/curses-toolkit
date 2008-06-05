#!perl -Tw

use Test::More;

my @modules = qw(
    Curses
    Curses::Toolkit
	Params::Validate
);

plan tests => scalar(@modules);

# try to load all modules
foreach my $module (@modules) {
    use_ok( $module );
}
