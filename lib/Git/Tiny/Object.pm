package Git::Tiny::Object;
use strict;
use Digest::SHA1 ();
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(kind content size _sha1) ]
;

sub sha1 {
    my $self = shift;
    if (@_) {
        $self->_sha1(@_);
    } else {
        my $sha1 = $self->_sha1;
        if (! $sha1) {
            $sha1 = $self->compute_sha1();
            $self->_sha1($sha1);
        }
        return $sha1;
    }
}

sub compute_sha1 {
    return Digest::SHA1::sha1_hex($_[0]->kind, " ", $_[0]->size, "\0", $_[0]->content);
}

1;