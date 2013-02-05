package Git::Tiny::DirEntry;
use strict;
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(mode filename sha1) ]
;

1;
