# A class to provide the gpg agent package
class gpg::install (
  $ensure      = present,
  $pkg_version = latest
) {

  case $::operatingsystem {
    'Debian', 'Ubuntu': { $gpg_agent_pkg = 'gnupg-agent' }
    'CentOS': { $gpg_agent_pkg = 'gnupg2' }
    default: {
      notify { "No gpg-agent package is configured for ${::operatingsystem}": }
    }
  }

  if $gpg_agent_pkg {
    package { $gpg_agent_pkg:
      ensure => $pkg_version
    }
  }
}
