# == Define: gpg::file
#
# Deploy and decrypt GPG protected files
#
# == TODO
#
#   * Add support for gpg-agent
#
define gpg::file(
  $source  = undef,
  $content = undef,
  $ensure  = 'present',
  $owner   = undef,
  $group   = undef,
  $mode    = undef,
) {

  if (!$content and !$source) or ($content and $source) {
    crit("gpg::file requires one of the [content, source] parameters defined")
  }

  require gpg::file::setup

  $temp_filename  = regsubst($name, '/', '_', 'G')
  $crypt_filepath = "${gpg::file::setup::gpgdir_real}/${temp_filename}.gpg"

  # Use secure file settings
  File {
    ensure => $ensure,
    backup => false,
  }

  file { $crypt_filepath:
    source  => $source,
    content => $content,
    owner   => 0,
    group   => 0,
    mode    => '0600',
  }

  if $ensure == 'present' {
    # If the file should be present, decrypt the file and cache the output. If
    # the decryption fails, wipe the file and fail so that the `creates`
    # parameter doesn't jam the works.
    exec { "decrypt ${name}":
      command   => "(gpg --output '${name}' --decrypt '${crypt_filepath}') || (rm -f '${name}'; /bin/false)",
      path      => '/usr/bin:/usr/local/bin',
      user      => 0,
      group     => 0,
      unless    => "test -s '${name}'",
      logoutput => on_failure,
      provider  => shell,
      subscribe => File[$crypt_filepath],
      before    => File[$name],
    }
  }

  file { $name:
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}
