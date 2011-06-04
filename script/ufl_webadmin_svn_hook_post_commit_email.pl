#!/usr/bin/env perl

use strict;
use warnings;
use UFL::WebAdmin::SVN::Hook::PostCommitEmail;

main(@ARGV);
sub main {
    my ($repository, $revision, @notifier_args) = @_;

    my $hook = UFL::WebAdmin::SVN::Hook::PostCommitEmail->new(
        repository    => $repository,
        revision      => $revision,
        notifier_args => \@notifier_args,
    );

    $hook->run;
}
