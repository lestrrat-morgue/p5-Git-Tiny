package Git::Tiny::Cmd;
use strict;
use Git::Tiny;
use Class::Accessor::Lite
    new => 1,
    rw => [ qw(git) ]
;

sub run {
    my $self = shift;

    my $cmd = shift @ARGV;
    my $method = "cmd_$cmd";
    my $code = $self->can($method);
    if ($code) {
        $code->($self, @ARGV);
    }
}

sub get_git {
    my $self = shift;
    my $git = $self->git();
    if ($git) {
        return $git;
    }

    my $git_dir = Git::Tiny::find_git_dir();
    if (! -d $git_dir) {
        die "fatal Not a git repository (or any of the parent directories): .git\n"
    }
    $git = Git::Tiny->new(dir => $git_dir);
    $self->git($git);
    return $git;
}

sub cmd_log {
    my ($self, @args) = @_;

    my $git = $self->get_git();

    # XXX need to know what branch we're in -- unimplemented.
    # just do master for now
    my $commit = $git->get_ref("refs/heads/master");
    while ($commit) {
        # XXX format must be configurable -- unimplemented
        print "commit ", $commit->sha1, "\n";
        print "Author: ", $commit->author, "\n";
        print "Date: ", "Unimplemented", "\n";
        print "\n";
        print "    ", $commit->content, "\n";


        my $parent = $commit->parent;
        if ($parent) {
            $commit = $git->get_object($commit->parent);
        } else {
            undef $commit;
        }
    }
}

1;
