require 'chef/mixin/shell_out'

module Machine
  module Docker
    extend Chef::Mixin::ShellOut

    def self.binary
      '/usr/bin/docker'
    end

    def self.version
      o = shell_out("#{binary} --version")
      o.stdout.split[2].chomp(',')
    end
  end

  module DockerHelpers
    def registrator_ignore_labels(ports_or_exposelist)
      Array(ports_or_exposelist).map do |port|
        port = port.to_s.split(':').last.gsub(%r{\/(tcp|udp)$}, '')
        "SERVICE_#{port}_IGNORE:yes"
      end.uniq
    end
  end
end
