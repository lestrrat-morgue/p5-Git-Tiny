package Git::Tiny::Object::Blob;
use strict;
use base qw(Git::Tiny::Object);

sub new {
    my $class = shift;
    $class->SUPER::new(kind => "blob", @_);
}

1;