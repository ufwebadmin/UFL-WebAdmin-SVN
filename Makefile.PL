use inc::Module::Install;

name     'UFL-WebAdmin-SVN';
all_from 'lib/UFL/WebAdmin/SVN.pm';

requires 'SVN::Notify';

# For script/*.sh
requires_external_bin '/bin/sh';
requires_external_bin '/usr/bin/svnlook';
requires_external_bin '/usr/bin/svnnotify';
requires_external_bin 'run-parts';

build_requires 'Test::More';

install_script glob('script/*.sh'), glob('script/*.py');

WriteAll;
