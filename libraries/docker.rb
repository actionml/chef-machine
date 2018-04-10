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

  module DockerRecipeMixin
    ## Define storage driver attribute
    #
    def define_storage_driver
      docker = version(Machine::Docker.version)
      kernel = version(node['kernel']['release'].split('-').first)

      # If we support overlay/overlay2 use it
      if kernel.satisfies?('>= 4.0') && docker.satisfies?('>= 1.12')
        node.default['machine']['engine']['storage_driver'] = 'overlay2'
      elsif kernel.satisfies?('>= 3.18')
        node.default['machine']['engine']['storage_driver'] = 'overlay'
      else
        node.default['machine']['engine']['storage_driver'] = nil
      end
    end

    ## Define docker engine listens attribute
    #
    def define_listners
      bind_address = node['machine']['engine']['bind_address']
      port = node['machine']['engine']['port']
      if bind_address && port
        node.default['machine']['engine']['listens'] <<
          "tcp://#{bind_address}:#{port}"
      else
        Chef::Log.warn('[machine] Docker engine might not listen on TCP, ' \
                       'define bind_address and port!')
      end
    end

    def setup_docker_engine
      define_listners
      define_storage_driver

      node['machine']['engine']
    end
  end
end
