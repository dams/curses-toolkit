use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Curses::Toolkit',
    AUTHOR              => 'Damien "dams" Krotkine <dams@cpan.org>',
    VERSION_FROM        => 'lib/Curses/Toolkit.pm',
    ABSTRACT_FROM       => 'lib/Curses/Toolkit.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Curses' => 0,
        'Test::More' => 0,
        'Tie::Array::Iterable' => 0,
        'parent' => 0,
		'use List::MoreUtils' => 0,
		'POE' => 0,
		'Params::Validate' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Curses-Toolkit-*' },
);
