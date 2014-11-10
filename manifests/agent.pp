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
  $outfile        = '',
  $path           = '/usr/bin:/bin:/usr/sbin:/sbin',
  $options        = [],
  $gpg_passphrase = undef,
  $gpg_key_grip   = undef,
  $user           = $name
) {

  require gpg

  if $outfile == '' {
    $gpg_agent_info = "/home/${name}/.gpg-agent-info"
  }
  else {
    $gpg_agent_info = $outfile
  }

  $command            = inline_template('<%= "gpg-agent --allow-preset-passphrase --write-env-file #{gpg_agent_info} --daemon #{options.join(\' \').gsub(/\s+/, \' \')}" %>')
  $preload_passphrase = "/usr/lib/gnupg2/gpg-preset-passphrase -v --passphrase ${gpg_passphrase} --preset ${gpg_key_grip}"

  Exec {
    path => $path,
    user => $user
  }

  case $ensure {
    present: {
      exec { "gpg-agent for ${name}":
        command   => $command,
        unless    => "ps -U ${user} -o args | grep -v grep | grep gpg-agent",
        logoutput => on_failure,
      }
      if $gpg_passphrase {
        exec { "set gpg-agent ${name} passphrase":
          command     => $preload_passphrase,
          onlyif      => "ps -U ${user} -o args | grep -v grep | grep gpg-agent",
          refreshonly => true,
          subscribe   => Exec["gpg-agent for ${name}"]
        }
      }
    }
    absent: {
      exec { "kill gpg-agent for ${name}":
        command => "ps -U ${name} -eo pid,args | grep -v grep | grep gpg-agent | xargs kill",
        onlyif  => "ps -U ${name} -o args | grep -v grep | grep gpg-agent",
      }
    }
    default: {
      fail("Undefined ensure parameter \"${ensure}\" for gpg::agent")
    }
  }
}
