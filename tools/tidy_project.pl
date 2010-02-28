#!/usr/bin/perl

use strict;
use warnings;

eval('require Perl::Tidy');
$@ and die 'Please install Perl::Tidy (e.g. cpan Perl::Tidy)';

use Cwd                   qw( cwd );
use File::Spec::Functions qw( catfile catdir );
use File::Find::Rule;
use FindBin qw( $Bin );
use Path::Class qw( dir );

# check if perltidyrc file exists
my $perltidyrc = catfile( $Bin, 'perltidyrc' );
-e $perltidyrc
  or die "cannot find perltidy configuration file: $perltidyrc\n";

my $root_dir = dir($Bin)->parent;

my $lib_dir = $root_dir->subdir('lib');
my @files = @ARGV || File::Find::Rule->file->name("*.pm")->in("$lib_dir");

# formatting documents
my $cmd = "perltidy --backup-and-modify-in-place --profile=$perltidyrc @files";

system($cmd)
  and die "perltidy exited with return code " . ($? >> 8);

# removing backup files
unlink map { $_ . '.bak'} @files;
