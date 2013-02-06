package Git::Tiny::Object::Commit;
use strict;
use base qw(Git::Tiny::Object);
use Class::Accessor::Lite
    rw => [ qw(parent tree author committer) ]
;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(kind => "commit", @_);
    $self->parse_content();
    return $self;
}

sub parse_content {
    my $self = shift;
    my $content = $self->content;

    my $index = index($content, "\n");
    while ($index > 0) {
        my ($attr, $value) = split(/\s+/, substr($content, 0, $index, ''), 2);
        $self->$attr($value);
        substr($content, 0, 1, '');
        $index = index($content, "\n");
    }
    substr($content, 0, 1, '');
    $self->content($content);
}

1;