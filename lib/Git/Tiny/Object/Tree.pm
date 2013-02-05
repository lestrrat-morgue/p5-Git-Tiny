package Git::Tiny::Object::Tree;
use strict;
use base qw(Git::Tiny::Object);
use Git::Tiny::DirEntry;
use Class::Accessor::Lite
    rw => [ qw(_entries) ]
;

sub new {
    my $class = shift;
    $class->SUPER::new(kind => "tree", @_);
}

sub entries {
    my $self = shift;
    if (@_) {
        $self->_entries(@_);
    } else {
        my $entries = $self->_entries;
        if (! $entries) {
            $entries = $self->parse_content();
            $self->_entries($entries);
        }
        return $entries;
    }
}

sub parse_content {
    my $self = shift;

    my $content = $self->content;
    my @ret;
    while ($content) {
        my ($mode, $filename) = split (/\s+/, substr($content, 0, index($content, "\0"), ''), 2);
        substr($content, 0, 1, '');
        my $sha1 = unpack("H*", substr($content, 0, 20, ''));
        push @ret, Git::Tiny::DirEntry->new(
            mode => $mode,
            filename => $filename,
            sha1 => $sha1
        );
    }
    return \@ret;
}

1;