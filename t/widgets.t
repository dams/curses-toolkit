#!perl

use strict;
use warnings;

use File::Temp;
use IO::Pty::Easy;
use Test::More;

use FindBin qw($Bin);
use Path::Class;

my $widgets_dir = dir($Bin, 'widgets');

foreach my $widget_file ($widgets_dir->children) {
    $widget_file->is_dir
      and next;
    my $content = $widget_file->slurp;
    my $fh = File::Temp->new( UNLINK=>1 );
    $fh->print($content);
    $fh->close;
    my $pty = IO::Pty::Easy->new;
    $pty->spawn( "$^X -I$Bin/../lib -I$Bin/lib $fh 2>&1 >/dev/null" );
    my $output = '';
    while ($pty->is_active) {
        my $read = $pty->read(0);
        defined $read
          or next;
        $output .= $read;
    }
    $pty->close;
    my @args;
    my ($current_arg, $test_type);

    foreach my $line (split("\n", $output)) {
        if ($line =~ /^__TEST_(..)__$/) {
            $test_type = lc($1);
        }
        elsif ($line =~ /^__ARG(\d)__$/) {
            $current_arg = \($args[$1]);
        }
        elsif ($line eq "__END_TEST__") {
            $test_type eq 'ok'
              and ok($args[0], $args[1]);
            $test_type eq 'is'
              and is($args[0], $args[1], $args[2]);
            $current_arg = undef;
            @args = ();
        } else {
            if ($current_arg) {
                $$current_arg .= $line;
            } else {
                print STDERR $line
            }
        }
    }
}


done_testing;
