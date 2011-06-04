#!perl

use strict;
use warnings;
use FindBin;
use IO::String;
use Path::Class;
use Test::More;

BEGIN { use_ok('UFL::WebAdmin::SVN::Hook::PostCommitEmail'); }

my $config = dir($FindBin::Bin)->subdir('data')->file('ufl-webadmin-svn.ini');

my $repository = dir($FindBin::Bin)->subdir('data', 'repo');

my $hook = UFL::WebAdmin::SVN::Hook::PostCommitEmail->new(
    config     => "$config",
    repository => "$repository",
    revision   => 1,
);

isa_ok($hook, 'UFL::WebAdmin::SVN::Hook::PostCommitEmail');
isa_ok($hook->notifier, 'SVN::Notify');

my $output;
my $io = IO::String->new($output);

$hook->prepare;
$hook->output($io);

like($output, qr/^From:\s+dwc\@ufl\.edu/m, 'Found the From: header');
like($output, qr/^To:\s+dwc\@ufl\.edu/m, 'Found the To: header');
like($output, qr/^Subject:\s+\[1\] Here's a file/m, 'Found the Subject: header');
like($output, qr/Revision:\s+1/, 'Found a revision');
like($output, qr/Author:\s+dwc/, 'Found an author');
like($output, qr/Added Paths:/, 'Commit information matches');

done_testing();
