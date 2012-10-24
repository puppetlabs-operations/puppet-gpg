# == Class: gpg::file::setup
#
# Sets up a drop point for gpg encrypted files
#
# == Requirements
#
#   * puppetlabs-stdlib for the `puppet_vardir` fact
#
class gpg::file::setup($gpgdir = undef) {

  $gpgdir_real = $gpgdir ? {
    undef   => "${puppet_vardir}/gpg",
    default => $gpgdir,
  }

  # Encrypted files are cached here
  $cryptdir = "${gpgdir_real}/crypt"
  # Decrypted files ready for staging are kept here
  $stagedir = "${gpgdir_real}/stage"

  file { [$gpgdir_real, $cryptdir, $stagedir]:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0700',
    purge   => true,
    recurse => true,
    backup  => false,
  }
}
