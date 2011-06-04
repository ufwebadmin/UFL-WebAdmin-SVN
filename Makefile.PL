use inc::Module::Install;

name     'UFL-WebAdmin-SVN';
all_from 'lib/UFL/WebAdmin/SVN.pm';

requires 'Carp';
requires 'Config::Any';
requires 'Getopt::Long';
requires 'Hash::Merge';
requires 'Moose';
requires 'SVN::Notify';

# For parsing .ini files
recommends 'Config::Tiny';

# For script/*.sh
requires_external_bin '/bin/sh';
requires_external_bin '/usr/bin/svnlook';
requires_external_bin '/usr/bin/svnnotify';
requires_external_bin 'find';
requires_external_bin 'run-parts';
requires_external_bin 'svnadmin';
requires_external_bin 'trac-admin';

build_requires 'FindBin';
build_requires 'IO::String';
build_requires 'Path::Class';
build_requires 'Test::More';

install_script
    glob('script/*.pl'),
    glob('script/*.py'),
    glob('script/*.sh');

WriteAll;
