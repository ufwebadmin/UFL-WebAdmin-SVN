#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok('UFL::WebAdmin::SVN');
}

diag("Testing UFL::WebAdmin::SVN $UFL::WebAdmin::SVN::VERSION, Perl $], $^X");
