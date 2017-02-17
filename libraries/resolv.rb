
module Machine
  module ResolvHelpers

    CONF = '/etc/resolv.conf'
    IP = %r{(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])\.(?:[01]?\d\d?|2[0-4]\d|25[0-5])}
    FQDN = %r{(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])*$}

    def resolvconf
      if File.exist?(CONF)
        defaults = Mash.new(node['machine']['consul_options']['resolv_defaults'])
        conf = Mash.new()
        lines = File.readlines(CONF)

        conf[:nameservers] = lines.grep(/^nameserver #{IP}$/).map {|s| s[IP, 0]}
        conf[:searches] = lines.grep(/^search #{FQDN}$/).map {|s| s[FQDN, 0]}
        conf[:domains] = lines.grep(/^domain #{FQDN}$/).map {|s| s[FQDN, 0]}
      end

      defaults.merge(conf)
    end

  end
end
