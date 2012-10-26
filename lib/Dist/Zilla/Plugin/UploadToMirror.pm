package Dist::Zilla::Plugin::UploadToMirror;

use common::sense;
use namespace::autoclean;

use English '-no_match_vars';

use File::Spec;

use Net::SCP qw(scp);
use Net::SSH qw(ssh);

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(Str);

use Try::Tiny;

with 'Dist::Zilla::Role::Releaser';

has 'host'      => ( isa => Str, ro, required );
has 'site'      => ( isa => Str, ro, required );
has 'author'    => ( isa => Str, ro, required );
has 'directory' => ( isa => Str, ro, lazy_build );

#
# Version set by dist.ini; do not change here.
# VERSION
#

sub _build_directory 
{
    my $self = shift;

    my @args = 
      map { 
        substr( $self->author,0,$_ )
      } ( 1, 2, length($self->author) );

    return File::Spec->catdir(
        $self->site, authors => id => @args );
}

sub release 
{
    my($self,$archive) = @_;

    try { 
        scp(
            $archive,
            sprintf( '%s:%s', $self->host, $self->directory ) ); }
    catch { $self->log_fatal($ARG) };

    try {
        ssh(
            $self->host,
            sprintf( '/usr/bin/env cpansite --site %s index', $self->site ) ); }
    catch { $self->log_fatal($ARG) };

    $self->log( "$archive uploaded to " . $self->directory );

    return;
}

__PACKAGE__->meta->make_immutable();
no Moose;

1;

# ABSTRACT: Releaser plugin for uploading to Geekology mirror.
