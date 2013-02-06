package Git::Tiny;
use strict;
use Git::Tiny::Pack;
use Cwd ();
use File::Find ();
use File::Spec;
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(dir) ]
;
our $VERSION = '0.01';

sub path_to {
    my $self = shift;
    File::Spec->catfile($self->dir, @_);
}

sub path_to_object {
    my ($self, $sha1) = @_;
    $self->path_to("objects", substr($sha1, 0, 2), substr($sha1, 2, 38));
}

sub get_ref_sha1 {
    my ($self, $name) = @_;
    my $refs_dir = $self->path_to("refs");

    my $done = 0;
    my $sha1;
    File::Find::find({
        no_chdir => 1,
        wanted => sub {
            if ($done) {
                $File::Find::prune = 1;
                return;
            }

            if (!-f $File::Find::name) {
                return;
            }

            my $path = File::Spec->abs2rel($File::Find::name, $self->dir);
            if ($path eq $name) {
                $sha1 = do {
                    open my $fh, '<', File::Spec->rel2abs($File::Find::name, $refs_dir) or die;
                    local $/;
                    <$fh>
                };
                die if $@;
                $done = 1;
                return;
            }
        }
    }, $refs_dir);

    return $sha1 || ();
}

sub get_ref {
    my ($self, $name) = @_;
    my $sha1 = $self->get_ref_sha1($name);
    if (! $sha1) {
        Carp::confess("Could not find ref $name");
    }
    return $self->get_object( $sha1 );
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
    $git->get_ref("refs/heads/master");

=cut