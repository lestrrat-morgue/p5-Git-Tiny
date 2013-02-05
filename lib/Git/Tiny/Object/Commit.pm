package Git::Tiny::Object::Commit;
use strict;
use base qw(Git::Tiny::Object);

sub new {
    my $class = shift;
    $class->SUPER::new(kind => "commit", @_);
}

1;