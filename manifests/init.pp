# == Class: gpg
#
# Manage GPG keys using GPGME
#
# === Parameters
#
# packagename,  defaults to gnupg2
#
# === Examples
#
#  include gpg
#
#    gpgkey { 'hiera':
#    ensure    => 'present',
#    email     => 'puppet@localhost',
#    }
#
#
#
# === Authors
#
# Craig Dunn <craig@craigdunn.org>
#
# === Copyright
#
# Copyright 2012 Craig Dunn
#
class gpg ($packagename  = 'gnupg2') {

  package { 'gnupg':
    name    => $packagename,
    ensure  => 'installed',
  }
}
