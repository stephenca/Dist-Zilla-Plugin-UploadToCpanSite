package Dist::Zilla::Plugin::UploadToCpanSite;

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
has 'cpan'      => ( isa => Str, ro, required, default =>
    'http://ftp.easynet.be/pub/CPAN/' );

#
# Version set by dist.ini; do not change here.
# VERSION
#

=pod

=head1 DESCRIPTION

  ; in dzil.ini
  [UploadToCpanSite]
  site        = /var/www/vhost/mycpansite/cpan
  host        = user@mycpansite.org
  author      = EXAMPLE

L<CPAN::Site> is a distribution for extending CPAN with private packages.  This
is a Dist::Zilla::Role::Releaser plugin that uploads a distribution tarball to
such a site, and regenerates the site indices. It is intended to be used instead of
L<Dist::Zilla::Plugin::UploadToCPAN>.

=head1 ATTRIBUTES

=head2 site

The base location of the L<CPAN::Site>, i.e. the value of CPANSITE_LOCAL in
L<CPAN::Site>'s terms.  This is mandatory.

=head2 host

The (user and) hostname at which the L<CPAN::Site> is hosted.  This is
mandatory.

Note that the user should have write permissions on the filesystem.

=head2 author

The CPAN author ID.  Mandatory.

=head2 directory

The location of the 'authors' directory in the L<CPAN::Site> site.
Optional.  If not supplied, is built from the 'site' and 'author' attributes,
e.g. from the sample dist.ini fragment above, the value of directory would be
'/var/www/vhosts/mycpansite/cpan/authors/id/E/EX/EXAMPLE'.

=head2 cpan

The location of the upstream CPAN archive (i.e. the value of CPANSITE_GLOBAL in L<CPAN::Site>'s
terms). Optional, defaults to http://ftp.easynet.be/pub/CPAN/.

=cut

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
        ssh(
            $self->host,
            sprintf(
                'mkdir -p %s',
                $self->directory ) ) }
    catch { $self->log_fatal($ARG) };

    my $scp = Net::SCP->new( { host => $self->host } );

    my $rc =
    try { 
        $scp->put(
            $archive, $self->directory ); }
    catch { $self->log_fatal($ARG) };

    if(!$rc) {
        $self->log_fatal( $scp->{errstr} );
    } else {
        my $rc =
        try {
            ssh(
                $self->host,
                sprintf(
                    '/usr/bin/env cpansite --site %s --cpan %s index',
                    $self->site,
                    $self->cpan ) ); }
        catch { $self->log_fatal($ARG) };
    
        $self->log( "$archive uploaded to " . $self->directory );
    }

    return;
}

__PACKAGE__->meta->make_immutable();
no Moose;

1;

# ABSTRACT: Releaser plugin for uploading to Geekology mirror.
