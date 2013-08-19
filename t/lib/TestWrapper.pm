package TestWrapper;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw(is ok create_root_window grab_frame);
our %EXPORT_TAGS = ('all' => \@EXPORT_OK);

use Curses::Toolkit;
use Curses::Toolkit::Theme::Default::Test;

sub create_root_window {
    my ($width, $height) = @_;
    Curses::Toolkit->init_root_window(
        test_environment => { screen_w => $width, screen_h => $height },
        theme_name => 'Curses::Toolkit::Theme::Default::Test'
    );
}

sub grab_frame {
    my ($root) = @_;
    $root->render;
    my @frame = map { ' ' x $root->{test_environment}{screen_w} }
      0..$root->{test_environment}{screen_h}-1;
    my @orders = $root->{_root_theme}->get_current_orders;
    foreach my $order (@orders) {
        my ($x, $y, $str) = @$order;
        substr($frame[$y], $x, length($str), $str);
    }

    join("\n", @frame);

}


sub ok {
    print STDERR "__TEST_OK__\n";
    print STDERR "__ARG0__\n";
    print STDERR $_[0] . "\n";
    print STDERR "__ARG1__\n";
    print STDERR $_[1] . "\n";
    print STDERR "__END_TEST__\n";
}

sub is {
    print STDERR "__TEST_IS__\n";
    print STDERR "__ARG0__\n";
    print STDERR $_[0] . "\n";
    print STDERR "__ARG1__\n";
    print STDERR $_[1] . "\n";
    print STDERR "__ARG2__\n";
    print STDERR $_[2] . "\n";
    print STDERR "__END_TEST__\n";
}


1;
