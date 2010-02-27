#!/usr/bin/perl

use strict;
use warnings;

eval("require Perl::Tidy");
if($@) {
	die "Please install Perl::Tidy (e.g. cpan Perl::Tidy)";
}

#
use Cwd                   qw{ cwd };
use File::Spec::Functions qw{ catfile catdir };
use File::Find::Rule;
use FindBin qw{ $Bin };

# check if perltidyrc file exists
my $perltidyrc = catfile( $Bin, 'perltidyrc' );
die "cannot find perltidy configuration file: $perltidyrc\n"
	unless -e $perltidyrc;

# build list of perl files to reformat
my @pmfiles = @ARGV
	? @ARGV
	: grep {/^lib/}	File::Find::Rule->file->name("*.pm")->relative->in(cwd);
my @tfiles = @ARGV
	? @ARGV
	: grep {/^t/}	File::Find::Rule->file->name("*.t")->relative->in(cwd);
my @examples  = @ARGV
	? @ARGV
	: grep {/^examples/} File::Find::Rule->file->name("*.pl")->relative->in(cwd);

my @files = (@pmfiles, @tfiles, @examples);

# formatting documents
my $cmd = "perltidy --backup-and-modify-in-place --profile=$perltidyrc @files";
system($cmd) == 0 or die "perltidy exited with return code " . ($? >> 8);

# removing backup files
unlink map {"$_.bak"} @files;
