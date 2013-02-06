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

sub find_git_dir {
    my $dir = Cwd::abs_path();
    while ($dir) {
        my $git_dir = File::Spec->catdir($dir, ".git");
        # XXX Can't be enough. check what needs to be checked later.
        if (-d $git_dir) {
            return $git_dir;
        }
        $dir = Cwd::abs_path(File::Spec->catdir($dir, File::Spec->updir));
    }
    return;
}

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

sub get_head {
    my ($self) = @_;
    # XXX Need to encapsulate this?
    my $path = $self->path_to("HEAD");
    my $content = do {
        open my $fh, '<', $path or die;
        local $/;
        <$fh>;
    };
    die if $@;
    chomp $content;
    $content =~ s/^ref:\s+//;
    $self->get_ref($content);
}

sub get_object {
    my ($self, $sha1) = @_;
    # XXX deltified objects are not supported yet

    my $path = $self->path_to_object($sha1);
    my $pack = Git::Tiny::Pack->new(git => $self, filename => $path);
    $pack->unpack_object();
}

sub format_object {
    my ($self, $object, $pattern) = @_;
    if ($object->isa('Git::Tiny::Object::Commit')) {
        $pattern ||= "commit %H%nAuthor: %an%nDate: %ad%n%n%b%n";
    }

    my $output;
    while ($pattern && $pattern =~ s/^([^%]*)(%)?//smx) {
        if ($1) {
            $output .= $1;
        }
        next unless $2;

        # XXX note: try longest candidates first
        if ($pattern =~ s/^ad//) {
            $output .= "Unimplemented";
        } elsif ($pattern =~ s/^an//) {
            $output .= $object->author;
        } elsif ($pattern =~ s/^b//) {
            $output .= $object->content;
        } elsif ($pattern =~ s/^H//) {
            $output .= $object->sha1;
        } elsif ($pattern =~ s/^n//) {
            $output .= "\n";
        } else {
            die "no match $pattern";
        }
    }
    return $output;
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