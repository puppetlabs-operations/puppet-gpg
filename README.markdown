Puppet Module: gpg
==================

Manage the creation of GPG private keys and gpg-agent

This module  gives a type and provider for managing and creating gpg keys on the fly - useful for sites running hiera-gpg

Example:
  gpgkey { 'hiera':
    ensure    => present,
    email     => 'puppet@puppet.mydomain.com',
  }

Contributors
------------

  * gpgkey, tests, and class gpgkey created by Craig Dunn (cr
  * gpg::agent created by Puppet Labs Operations

License
-------

Code contributed by Puppet Labs Operations is Apache 2.0; see LICENSE.

All other code is copyright Craig Dunn; all rights reserved.

Support
-------

Please log tickets and issues at our [Projects site](https://github.com/puppetlabs-operations/puppet-gpg/issues)
