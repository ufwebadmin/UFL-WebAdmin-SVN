#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use Test::More tests => 2;

my $script = dir($FindBin::Bin)->parent->subdir('script')->file('ufl_webadmin_svn_postcommit.sh');
ok(-x $script, 'post-commit script is executable');

my $repo = dir($FindBin::Bin)->subdir('data', 'repo');
my $output = qx{$script $repo 1};
chomp $output;
is($output, "REPO = [$repo], REV = [1]", "post-commit plugin script ran successfully");
