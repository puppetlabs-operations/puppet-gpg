# == Class: gpg::ruby
#
# Create and manage GPG keys using ruby-gpgme
#
# === Parameters
#
# packagename,  defaults to gnupg2
#
# === Examples
#
#  include gpg::ruby
#
#    gpgkey { 'hiera':
#      ensure    => 'present',
#      email     => 'puppet@localhost',
#    }
#
class gpg::ruby($provider = 'gem') {

  include gpg
  include ruby::dev

  package { 'gpgme':
    ensure    => 'present',
    provider  => $provider,
    require   => Class['gpg', 'ruby::dev'],
  }
}
