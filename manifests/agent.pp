# Ensures that a gpg-agent instance is running for a specific user
#
# == Parameters
#
#
# == Examples
#
# gpg::agent { "git":
#   ensure => present,
# }
#
define gpg::agent (
  $ensure         = present,
  $outfile        = "/home/${name}/.gpg-agent-info",
  $path           = '/usr/bin:/bin:/usr/sbin:/sbin',
  $options        = [],
  $gpg_passphrase = undef,
  $gpg_key_grip   = undef,
  $user           = $name
) {

  require gpg

  $check_for_agent = 'sh -c gpg-agent'

  case $ensure {
    present: {
      exec { "gpg-agent for ${name}":
        path      => $path,
        user      => $user,
        unless    => $check_for_agent,
        logoutput => on_failure,
        command   => join( [
          'gpg-agent',
          '--allow-preset-passphrase',
          '--write-env-file',
          $outfile,
          '--daemon',
          join($options, ' ')
        ], ' ')
      }
      if $gpg_passphrase {
        exec { "set gpg-agent ${name} passphrase":
          path        => $path,
          user        => $user,
          onlyif      => $check_for_agent,
          refreshonly => true,
          subscribe   => Exec["gpg-agent for ${name}"],
          command     => join( [
            '/usr/lib/gnupg2/gpg-preset-passphrase -v',
            '--passphrase',
            $gpg_passphrase,
            '--preset',
            $gpg_key_grip,
          ], ' ')
        }
      }
    }
    absent: {
      exec { "kill gpg-agent for ${name}":
        path    => $path,
        user    => $user,
        command => 'ps aux | grep "[g]pg-agent --allow-preset-passphrase" | xargs kill',
        onlyif  => $check_for_agent,
      }
    }
    default: {
      fail("Undefined ensure parameter \"${ensure}\" for gpg::agent")
    }
  }
}
