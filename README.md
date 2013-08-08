# NAME

Dist::Zilla::Plugin::UploadToCpanSite - Dist::Zilla Releaser plugin for uploading to CPAN::Site mirror.

# VERSION

version 1.132200

# DESCRIPTION

    ; in dzil.ini
    [UploadToCpanSite]
    site        = /var/www/vhost/mycpansite/cpan
    host        = user@mycpansite.org
    author      = EXAMPLE

[CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site) is a distribution for extending CPAN with private packages.  This
is a Dist::Zilla::Role::Releaser plugin that uploads a distribution tarball to
such a site, and regenerates the site indices. It is intended to be used instead of
[Dist::Zilla::Plugin::UploadToCPAN](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::UploadToCPAN).

# ATTRIBUTES

## site

The base location of the [CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site), i.e. the value of CPANSITE\_LOCAL in
[CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site)'s terms.  This is mandatory.

## host

The (user and) hostname at which the [CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site) is hosted.  This is
mandatory.

Note that the user should have write permissions on the filesystem.

## author

The CPAN author ID.  Mandatory.

## directory

The location of the 'authors' directory in the [CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site) site.
Optional.  If not supplied, is built from the 'site' and 'author' attributes,
e.g. from the sample dist.ini fragment above, the value of directory would be
'/var/www/vhosts/mycpansite/cpan/authors/id/E/EX/EXAMPLE'.

## cpan

The location of the upstream CPAN archive (i.e. the value of CPANSITE\_GLOBAL in [CPAN::Site](http://search.cpan.org/perldoc?CPAN::Site)'s
terms). Optional, defaults to http://ftp.easynet.be/pub/CPAN/.

# METHODS

## release ( $archive )

    This method does three things:

    1. Calls 'mkdir $self->directory' on the remote host.
    2. Transfers the archive to this location via scp.
    3. Executes 'cpansite index' on the remote host.

    Failure to perform any of these is a fatal error.

# AUTHOR

Stephen Cardie <stephenca@ls26.net>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Stephen Cardie <stephenca@ls26.net>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
