package Git::Tiny::Pack;
use strict;
use Git::Tiny::Object::Blob;
use Git::Tiny::Object::Commit;
use Git::Tiny::Object::Tree;
use Compress::Zlib ();
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(filename) ]
;

sub unpack_object {
    my ($self) = @_;

    my $file = $self->filename;
    open my $fh, '<', $file or
        die "Failed to open $file: $!";
    local $/;
    my $content = Compress::Zlib::uncompress(<$fh>);

    my ($type, $length);
    $content =~ s/\A(\w+)\s+(\d+)\0/$type = $1; $length = $2; ''/msxe;
    if ($type eq 'blob') {
        return Git::Tiny::Object::Blob->new(
            size => $length,
            content => $content
        );
    } elsif ($type eq 'commit') {
        return Git::Tiny::Object::Commit->new(
            size => $length,
            content => $content
        );
    } elsif ($type eq 'tree') {
        return Git::Tiny::Object::Tree->new(
            size => $length,
            content => $content
        );
    } else {
        Carp::confess("Unknown git pack type $type");
    }
}

1;

__END__

=head1 NAME

Git::Tiny::Pack - A Packed Object

=head1 SYNOPSIS

    use Git::Tiny::Pack;

    my $pack = Git::Tiny::Pack->new(filename => ".git/objects/xx/xxxxxxxxxxxxxxxxxxx");
    my $object = $pack->unpack_object();

=cut