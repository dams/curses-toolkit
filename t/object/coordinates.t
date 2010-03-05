#!perl

use strict;
use warnings;

use File::Temp;
use IO::Pty::Easy;
use Test::More tests => 70;
use Test::Exception;

use aliased 'Curses::Toolkit::Object::Coordinates';

use Curses::Toolkit;
use Curses::Toolkit::Widget::Window;

my ($c0, $c1, $c2, $c3, $c4);


# -- different constructors

# - new_zero()
$c0 = Coordinates->new_zero;
isa_ok( $c0, 'Curses::Toolkit::Object::Coordinates', 'new_zero() creates a coords' );
is( "$c0", '0x0+0x0', 'new object is null' );

# - new()
$c1 = Coordinates->new( x1=>1, y1=>4, x2=>2, y2=>6 );
isa_ok( $c1, 'Curses::Toolkit::Object::Coordinates', 'new(@coords) creates a coords' );
is( "$c1", '1x2+1x4', 'new object stringifies correctly' );

$c2 = Coordinates->new( x1=>1, y1=>4, width=>1, height=>2 );
isa_ok( $c2, 'Curses::Toolkit::Object::Coordinates', 'new(@start, @len) creates a coords' );
is( "$c2", '1x2+1x4', 'new object stringifies correctly' );

my $len = 12;
$c3 = Coordinates->new( x1=>sub{$len/6}, y1=>sub{$len/3}, x2=>sub{$len/4}, y2=>sub{$len/2} );
isa_ok( $c3, 'Curses::Toolkit::Object::Coordinates', 'new(@callbacks) creates a coords' );
is( "$c3", '1x2+2x4', 'new object stringifies correctly' );
$len = 24;
is( "$c3", '2x4+4x8', 'coord callbacks update' );

$c4 = Coordinates->new( $c1 );
isa_ok( $c4, 'Curses::Toolkit::Object::Coordinates', 'new($obj) creates a coords' );
is( "$c4", '1x2+1x4', 'new object stringifies correctly' );

# normalize option
$c1 = Coordinates->new( x1=>2, y1=>6, x2=>1, y2=>4, normalize=>1 );
is( "$c1", '1x2+1x4', 'normalizing object works' );

# constructor params validation
throws_ok { Coordinates->new( x1=>1, y1=>4, width=>1, y2=>2 ) } qr/not listed/, 'need both width & height';

# - clone()
$c1 = Coordinates->new( x1=>10, y1=>5, x2=>3, y2=>1 );
$c2 = $c1->clone;
is( "$c2", "$c1", 'cloned object has the same coords' );
ok( $c1 == $c2, 'cloned objects are detected equal' );
$c2->set( x1 => 12 );
isnt( "$c2", "$c1", 'cloned object is a different object' );

# -- accessors
$c1 = Coordinates->new( x1=>8, y1=>1, x2=>9, y2=>4 );
is( $c1->get_x1, 8, 'get_x1() works' );
is( $c1->get_y1, 1, 'get_y1() works' );
is( $c1->get_x2, 9, 'get_x2() works' );
is( $c1->get_y2, 4, 'get_y2() works' );
is( $c1->width,  1, 'width() works' );
is( $c1->height, 3, 'height() works' );


# -- set()
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>10, y2=>4 );
$c1->set( x1=>8 );
is( "$c1", "2x3+8x1", 'set works' );
$c1->set( x1=>4, y1=>2, x2=>9, y2=>3 );
is( "$c1", "5x1+4x2", 'set with multiple values works' );
$c1->set( x1=>10, y1=>5, x2=>3, y2=>1 );
is( "$c1", '7x4+3x1', 'set automatically normalizes' );
throws_ok { $c1->set( width=>1 ) } qr/not listed/, 'cannot set width';


# -- add()
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
$c1->add( 3 );
is( "$c1", '2x3+6x4', 'add(const) works' );
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
$c2 = Coordinates->new( x1=>2, y1=>1, x2=>3, y2=>5 );
$c1->add( $c2 );
is( "$c1", '3x7+5x2', 'add(coords)' );
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
my %add = ( x1=>1, y1=>2, x2=>4, y2=>7 );
$c1->add( \%add );
is( "$c1", '5x8+4x3', 'add(hashref)' );
throws_ok { $c1->add([]) } qr/not supported/, 'cannot add whatever';


# -- overloaded addition
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
$c2 = Coordinates->new( x1=>2, y1=>1, x2=>3, y2=>5 );
$c3 = $c1 + $c2;
is( "$c1", '2x3+3x1', 'original coord1 does not change' );
is( "$c2", '1x4+2x1', 'original coord2 does not change' );
is( "$c3", '3x7+5x2', 'new coord returned' );


# -- add()
$c1 = Coordinates->new( x1=>4, y1=>3, x2=>5, y2=>4 );
$c1->subtract( 3 );
is( "$c1", '1x1+1x0', 'subtract(const) works' );
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
$c2 = Coordinates->new( x1=>2, y1=>1, x2=>3, y2=>2 );
$c1->subtract( $c2 );
is( "$c1", '1x2+1x0', 'subtract(coords)' );
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
my %rm = ( x1=>2, y1=>1, x2=>3, y2=>2 );
$c1->subtract( \%rm );
is( "$c1", '1x2+1x0', 'subtract(hashref)' );
throws_ok { $c1->subtract([]) } qr/not supported/, 'cannot remove whatever';


# -- overloaded subtraction
$c1 = Coordinates->new( x1=>3, y1=>1, x2=>5, y2=>4 );
$c2 = Coordinates->new( x1=>2, y1=>1, x2=>3, y2=>2 );
$c3 = $c1 - $c2;
is( "$c1", '2x3+3x1', 'original coord1 does not change' );
is( "$c2", '1x1+2x1', 'original coord2 does not change' );
is( "$c3", '1x2+1x0', 'new coord returned' );


# -- restrict_to()
$c1 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c2 = Coordinates->new( x1=>3, y1=>4, x2=>6, y2=>8 );
$c1->restrict_to($c2);
is( "$c1", '3x4+3x4', 'restrict_to() on all coords' );
$c1 = Coordinates->new( x1=>3, y1=>4, x2=>6, y2=>8 );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c1->restrict_to($c2);
is( "$c1", '3x4+3x4', 'restrict_to() on no coords' );


# -- grow_to()
$c1 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c2 = Coordinates->new( x1=>3, y1=>4, x2=>6, y2=>8 );
$c1->grow_to($c2);
is( "$c1", '9x9+0x0', 'restrict_to() on no coords' );
$c1 = Coordinates->new( x1=>3, y1=>4, x2=>6, y2=>8 );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c1->grow_to($c2);
is( "$c1", '9x9+0x0', 'restrict_to() on all coords' );


# -- translate()
$c1 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c1->translate( x=>1 );
is( "$c1", '9x9+1x0', 'translate() with x' );
$c1->translate( y=>1 );
is( "$c1", '9x9+1x1', 'translate() with y' );
$c1->translate( x=>1,y=>1 );
is( "$c1", '9x9+2x2', 'translate() with x & y' );


# -- translate_*()
$c1 = Coordinates->new( x1=>0, y1=>0, x2=>4, y2=>5 );
$c1->translate_down( 1 );
is( "$c1", '4x5+0x1', 'translate_down()' );
$c1->translate_down( -1 );
is( "$c1", '4x5+0x2', 'translate_down() with negative' );
$c1->translate_up( 1 );
is( "$c1", '4x5+0x1', 'translate_up()' );
$c1->translate_up( -1 );
is( "$c1", '4x5+0x0', 'translate_up() with negative' );
$c1->translate_right( 1 );
is( "$c1", '4x5+1x0', 'translate_right()' );
$c1->translate_right( -1 );
is( "$c1", '4x5+2x0', 'translate_right() with negative' );
$c1->translate_left( 1 );
is( "$c1", '4x5+1x0', 'translate_left()' );
$c1->translate_left( -1 );
is( "$c1", '4x5+0x0', 'translate_left() with negative' );


# -- contains() / is_inside()
$c1 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
$c2 = Coordinates->new( x1=>3, y1=>4, x2=>6, y2=>8 );
ok(   $c1->contains($c2),  'contains() true' );
ok(   $c2->is_inside($c1), 'is_inside() true' );
ok( ! $c2->contains($c1),  'contains() all false' );
ok( ! $c1->is_inside($c2), 'is_inside() all false' );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
ok( $c1->contains($c2),  'contains() superposed' );
ok( $c1->is_inside($c2), 'is_inside() superposed' );
$c2 = Coordinates->new( x1=>-1, y1=>0, x2=>9, y2=>9 );
ok( ! $c1->contains($c2), 'contains() false on x1' );
$c2 = Coordinates->new( x1=>0, y1=>-1, x2=>9, y2=>9 );
ok( ! $c1->contains($c2), 'contains() false on y1' );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>10, y2=>9 );
ok( ! $c1->contains($c2), 'contains() false on x2' );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>10 );
ok( ! $c1->contains($c2), 'contains() false on y2' );
$c2 = Coordinates->new( x1=>1, y1=>0, x2=>9, y2=>9 );
ok( ! $c1->is_inside($c2), 'is_inside() false on x1' );
$c2 = Coordinates->new( x1=>0, y1=>1, x2=>9, y2=>9 );
ok( ! $c1->is_inside($c2), 'is_inside() false on y1' );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>8, y2=>9 );
ok( ! $c1->is_inside($c2), 'is_inside() false on x2' );
$c2 = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>8 );
ok( ! $c1->is_inside($c2), 'is_inside() false on y2' );


# -- is_in_widget()
# WARNING: this is very hackish
my $fh = File::Temp->new( UNLINK=>1 );
$fh->print(<<'EOF');
use aliased 'Curses::Toolkit::Object::Coordinates';

use Curses::Toolkit;
use Curses::Toolkit::Widget::Window;

sub myok {
    my ($bool, $text) = @_;
    my $status = $bool ? 1 : 0;
    print STDERR "$status|$text\n";
}
my $root = Curses::Toolkit->init_root_window();
my $c = Coordinates->new( x1=>0, y1=>0, x2=>9, y2=>9 );
my $w = Curses::Toolkit::Widget::Window->new;
$w->set_coordinates( x1=>3, y1=>4, x2=>6, y2=>8 );
myok( ! $c->is_in_widget($w), 'is_in_widget() all false' );
$w->set_coordinates( x1=>-1, y1=>-1, x2=>10, y2=>10 );
myok(   $c->is_in_widget($w), 'is_in_widget() all true' );
$w->set_coordinates( x1=>0, y1=>0, x2=>9, y2=>9 );
myok(   $c->is_in_widget($w), 'is_in_widget() superposed' );
$w->set_coordinates( x1=>1, y1=>0, x2=>9, y2=>9 );
myok( ! $c->is_in_widget($w), 'is_in_widget() false on x1' );
$w->set_coordinates( x1=>0, y1=>1, x2=>9, y2=>9 );
myok( ! $c->is_in_widget($w), 'is_in_widget() false on y1' );
$w->set_coordinates( x1=>0, y1=>0, x2=>8, y2=>9 );
myok( ! $c->is_in_widget($w), 'is_in_widget() false on x2' );
$w->set_coordinates( x1=>0, y1=>0, x2=>9, y2=>8 );
myok( ! $c->is_in_widget($w), 'is_in_widget() false on y2' );
EOF
$fh->close;
my $pty = IO::Pty::Easy->new;
$pty->spawn( "$^X $fh 2>&1 >/dev/null" );
my $output = '';
while ($pty->is_active) {
    my $read = $pty->read(0);
    next unless defined $read;
    $output .= $read;
}
$pty->close;
subtest 'testing is_in_widget()' => sub {
    my @tests = split /\n/, $output;
    plan tests => scalar(@tests);
    ok($_->[0],$_->[1]) for map { [ split /\|/, $_ ] } @tests;
};
