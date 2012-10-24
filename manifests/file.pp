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

  if((!$content) and (!$source)) {
    crit("gpg::file requires one of [content, source]")
  }

  require gpg::file::setup

  $temp_filename  = regsubst($name, '/', '_', 'G')
  $crypt_filepath = "${gpg::file::setup::cryptdir}/${temp_filename}.gpg"
  $stage_filepath = "${gpg::file::setup::stagedir}/${temp_filename}"

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
    exec { "decrypt ${crypt_filepath}":
      command   => "gpg --quiet --decrypt '${crypt_filepath}' > '${stage_filepath}' || (rm -f '${stage_filepath}'; /bin/false)",
      path      => '/usr/bin:/usr/local/bin',
      user      => 0,
      group     => 0,
      creates   => $stage_filepath,
      logoutput => on_failure,
      subscribe => File[$crypt_filepath],
      before    => File[$name],
      provider  => shell,
    }
  }

  # If the file should be absent, wipe the staged file. If it should be
  # present, manage the file so that it isn't wiped.
  file { $stage_filepath:
    owner  => 0,
    group  => 0,
    mode   => '0600',
  }

  file { $name:
    ensure => $ensure,
    source => $stage_filepath,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }
}
