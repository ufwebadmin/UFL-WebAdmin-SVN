#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use Test::More tests => 7;

my $script = dir($FindBin::Bin)->parent->subdir('script')->file('ufl_webadmin_svn_hook_runner.sh');
ok(-x $script, 'post-commit script is executable');

my $repo = dir($FindBin::Bin)->subdir('data', 'repo');

foreach my $hook (qw/post-commit post-revprop-change/) {
    my $hook_runner = dir($repo)->subdir('hooks')->file($hook);
    unlink $hook_runner;
    ok(! -f $hook_runner, "$hook symlink does not exist");

    system(qw/ln -s/, $script, $hook_runner);
    ok(-f $hook_runner, "$hook symlink exists");

    my $output = qx{$hook_runner $repo 1};
    chomp $output;
    is($output, "$hook: REPO = [$repo], REV = [1]", "$hook plugin script ran successfully");
}
