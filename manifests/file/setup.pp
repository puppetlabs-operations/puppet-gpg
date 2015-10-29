# == Class: gpg::file::setup
#
# Sets up a drop point for gpg encrypted files
#
# == Requirements
#
#   * puppetlabs-stdlib for the `puppet_vardir` fact
#
class gpg::file::setup(
  $gpgdir       = undef,
  $purge_gpgdir = true,
) {

  $gpgdir_real = $gpgdir ? {
    undef   => "${puppet_vardir}/gpg",
    default => $gpgdir,
  }

  file { $gpgdir_real:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0700',
    purge   => $purge_gpgdir,
    force   => true,
    recurse => true,
    backup  => false,
  }
}
