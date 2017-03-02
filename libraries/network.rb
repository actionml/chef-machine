
module Machine
  module NetworkHelpers

    CONF = '/etc/resolv.conf'
    IP = %r{(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])}
    FQDN = %r{(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])*$}

    ## /etc/resolv.conf parser (merged with)
    #
    def resolvconf
      conf = Mash.new()
      if File.exist?(CONF)
        lines = File.readlines(CONF)
        conf[:nameservers] = lines.grep(/^nameserver #{IP}$/).map {|s| s[IP, 0]}
        conf[:searches] = lines.grep(/^search #{FQDN}$/).map {|s| s[FQDN, 0]}
        conf[:domains] = lines.grep(/^domain #{FQDN}$/).map {|s| s[FQDN, 0]}
      end
      conf
    end

    ## Retrieve host ip addresses, equivalent to hostname -I
    # 
    def host_addresses
      interfaces = node['network']['interfaces'].select { |nk, nv| not (nv['flags'] || []).include? 'LOOPBACK' }
      addresses = interfaces.map do |ik, iv|
        iv['addresses'].select { |ak, av| av['family'] == 'inet' }
      end
      addresses.map { |hash| hash.keys }.flatten
    end

  end
end
