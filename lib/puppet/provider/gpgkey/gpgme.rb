begin
  require 'gpgme'
rescue LoadError => e
  Puppet.warning "Error while loading #{__FILE__}: #{e}; deferring require"
end

Puppet::Type.type(:gpgkey).provide(:gpgme) do
  def exists?
    ! GPGME::Key.find(:secret, keyname()).empty?
  end

  def create
    ctx = GPGME::Ctx.new
    keydata = "<GnupgKeyParms format=\"internal\">\n"
    keydata += "Key-Type: "       +@resource.value(:keytype)+"\n"
    keydata += "Key-Length: "     +@resource.value(:keylength)+"\n"
    keydata += "Subkey-Type: "    +@resource.value(:subkeytype)+"\n"
    keydata += "Subkey-Length: "  +@resource.value(:subkeylength)+"\n"
    keydata += "Name-Real: "      +@resource.value(:name)+"\n"
    keydata += "Name-Comment: "   +keyname()+"\n"
    keydata += "Name-Email: "     +@resource.value(:email)+"\n"
    keydata += "Expire-Date: "    +@resource.value(:expire)+"\n"
    keydata += "</GnupgKeyParms>\n"

    ctx.genkey(keydata, nil, nil)
  end

  def destroy
    GPGME::Key.find(:secret, keyname()).each do |key|
      key.delete!(true)
    end
  end

  private
  def keyname
    keyname = 'puppet#' + @resource.value(:name) + '#'
    return keyname
  end


  # If gpgme was not successfully loaded at autoload time, try to load it again
  # upon prefetch, in case it was installed prior to this provider being
  # pretched. If it's still not present, then this will throw an exception upon
  # prefetch and will be propagated down the stack as necessary.
  def self.prefetch(*args)
    unless defined? GPGME
      ::Gem.clear_paths
      require 'gpgme'
    end
  end
end
