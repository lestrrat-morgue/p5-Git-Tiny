use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => "Git-Tiny",
    VERSION_FROM => 'lib/Git/Tiny.pm',
    LICENSE => "artistic_2",
    AUTHOR    => 'Daisuke Maki C<< <daisuke@endeworks.jp> >>',
    PREREQ_PM => {
        'Class::Accessor::Lite' => 0,
        'Compress::Zlib' => 0,
    },
    BUILD_REQUIRES => {
    },
);


