package Git::Tiny::Object::Commit;
use strict;
use base qw(Git::Tiny::Object);

sub new {
    my $class = shift;
    $class->SUPER::new(kind => "commit", @_);
}

sub parse_content {
    my $self = shift;
    my $content = $self->content;

    my $index = index($content, "\n");
    while ($index > 0) {
        my ($attr, $value) = split(/\s+/, substr($content, 0, $index, ''), 2);
        $self->{$attr} = $value;
        substr($content, 0, 1, '');
        $index = index($content, "\n");
    }
}

BEGIN {
    foreach my $attr (qw(parent tree author committer)) {
        eval <<EOM;
            sub $attr {
                my (\$self) = \@_;
                if (! \$self->{$attr}) {
                    \$self->parse_content();
                }
                return \$self->{$attr};
        }
EOM
        die if $@
    }
}

1;