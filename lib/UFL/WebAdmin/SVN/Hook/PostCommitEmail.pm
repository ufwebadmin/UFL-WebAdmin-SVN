package UFL::WebAdmin::SVN::Hook::PostCommitEmail;

use Moose;
use Carp;
use Config::Any;
use Getopt::Long ();
use Hash::Merge;
use SVN::Notify;

=head1 NAME

UFL::WebAdmin::SVN::Hook::PostCommitEmail - Subversion post-commit hook for sending email notifications

=head1 SYNOPSIS

A Subversion post-commit hook that offers a configurable way to send
email notification of activity using L<SVN::Notify>.

Call using the corresponding script,
C<ufl_webadmin_hook_post_commit_email.pl>.

=head1 DESCRIPTION

This hook is a slim wrapper around L<SVN::Notify> that allows for easy
configuration. By default, it looks for a configuration file at:

C</etc/ufl-webadmin-svn.ini>

The file is parsed using L<Config::Any>. An example is provided below:

    [Hook::PostCommitEmail]
    from = webmaster@ufl.edu
    to = webadmin-commits-l@lists.ufl.edu
    subject_prefix = [WebAdmin SVN]
    subject_cx = 1
    with_diff = 1

Within the C<[Hook::PostCommitEmail]> section, the keys match the
names of L<SVN::Notify/Accessors>.

=head1 METHODS

=head2 config

The path to the configuration file. Default: C</etc/ufl-webadmin-svn.ini>

=head2 repository

The path to the Subversion repository, passed on the command line to
the corresponding script.

=head2 revision

The just-committed revision number, passed on the command line to the
corresponding script.

=head2 notifier_args

Extra arguments to pass to L<SVN::Notify>. Configuration is recommended
instead.

=head2 notifier

Accessor for the L<SVN::Notify> object.

=cut

has 'config'        => (is => 'rw', isa => 'Str', default => '/etc/ufl-webadmin-svn.ini');
has 'repository'    => (is => 'rw', isa => 'Str', required => 1);
has 'revision'      => (is => 'rw', isa => 'Int', required => 1);
has 'notifier_args' => (is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] });

has 'notifier' => (
    is      => 'rw',
    isa     => 'SVN::Notify',
    lazy    => 1,
    builder => '_build_notifier',
);

=head2 _build_notifier

Construct an L<SVN::Notify> object with any additional configuration we
can find.

=cut

sub _build_notifier {
    my ($self) = @_;

    # Start with values passed by Subversion
    my %params = (
        repos_path => $self->repository,
        revision   => $self->revision,
    );

    # Merge in configuration
    my $config = $self->_load_config;
    %params = %{ Hash::Merge::merge(\%params, $config) };

    # Merge in any additional options for SVN::Notify from command line
    my $args = $self->_parse_additional_args;
    %params = %{ Hash::Merge::merge(\%params, $args) };

    return SVN::Notify->new(%params);
}

=head2 _load_config

Load information from the L<UFL::WebAdmin::SVN> configuration file.

=cut

sub _load_config {
    my ($self) = @_;

    my $configs = Config::Any->load_files({
        files   => [ $self->config ],
        use_ext => 1,
    });

    my $config = {};
    if (@$configs) {
        $config = $configs->[0]->{$self->config}->{'Hook::PostCommitEmail'};
    }
    else {
        carp "No configuration loaded from [" . $self->config . "]; does it exist?";
    }

    return $config;
}

=head2 _parse_additional_args

Parse additional options for L<SVN::Notify> using
L<Getopt::Long/GetOptionsFromArray>.

=cut

sub _parse_additional_args {
    my ($self) = @_;

    my %args;
    Getopt::Long::GetOptionsFromArray($self->notifier_args, \%args);

    return \%args;
}

=head2 prepare

Alias for L<SVN::Notify/prepare>.

=head2 output

Alias for L<SVN::Notify/output>.

=head2 execute

Alias for L<SVN::Notify/execute>.

=cut

sub prepare { shift->notifier->prepare(@_) }
sub output  { shift->notifier->output(@_) }
sub execute { shift->notifier->execute(@_) }

=head2 run

Convenience method for L</prepare> and L</execute>.

=cut

sub run {
    my ($self) = @_;

    $self->prepare;
    $self->execute;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
