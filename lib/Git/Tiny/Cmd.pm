package Git::Tiny::Cmd;
use strict;
use Getopt::Long qw(:config gnu_compat no_auto_abbrev);
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
    my %opts;
    local @ARGV = @args;
    if (! GetOptions(\%opts, "format=s")) {
        exit 1;
    }

    # XXX need to parse options
    my $ref = shift @ARGV;
    my $commit = $ref ? $git->get_ref("refs/heads/$ref") : $git->get_head();
    while ($commit) {
        print $git->format_object($commit, $opts{format});

        my $parent = $commit->parent;
        if ($parent) {
            $commit = $git->get_object($commit->parent);
        } else {
            undef $commit;
        }
    }
}

sub cmd_show {
    my ($self, @args) = @_;

    local @ARGV = @args;
    if (! GetOptions(\%opts, "format=s")) {
        exit 1;
    }

    my $object = shift @ARGV;
    my $git = $self->get_git();

    my $sha1 = $object; # probably need to separete refs and sha1s
    my $object = $git->get_object($sha1);

    print $git->format_object($object);
}

sub cmd_diff {
    my ($self, @args) = @_;
}

1;
