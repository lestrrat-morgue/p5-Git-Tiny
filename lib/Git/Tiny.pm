package Git::Tiny;
use strict;
use Git::Tiny::Pack;
use File::Spec;
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(dir) ]
;
our $VERSION = '0.01';

sub path_to_object {
    my ($self, $sha1) = @_;
    File::Spec->catfile($self->dir, "objects", substr($sha1, 0, 2), substr($sha1, 2, 38));
}

sub get_object {
    my ($self, $sha1) = @_;
    # XXX deltified objects are not supported yet

    my $path = $self->path_to_object($sha1);
    my $pack = Git::Tiny::Pack->new(git => $self, filename => $path);
    $pack->unpack_object();
}

1;

__END__

=head1 NAME

Git::Tiny - Minimalistic Pure-Perl Git Implementation

=head1 SYNOPSIS

    use Git::Tiny;
    my $git = Git::Tiny->new(dir => "/path/to/git");

    $git->get_object($sha1);

=cut