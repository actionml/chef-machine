# List of the containers to bootstrap
default['machine']['bootstrap_containers'] = %w[consul swarm]

# Container defaults
default['machine']['container'] = {
  log_opts: %w[max-size=50m max-file=5]
}

## Container options such as image, log_opts, volumes etc.
#
default['machine']['containers'] = {
  consul: {
    image: 'stackfeed/consul:0.7-agent',
    docker_passthrough: true,
    confdir: '/etc/consul',
    exposed_ports: %w[
      8300:8300
      8301:8301 8301:8301/udp
      8302:8302 8302:8302/udp
      8400:8400
      8500:8500
    ],
    # currently set since resolution fails on Bionic
    network_mode: 'host',
    ## not redirect of the local dns to consul
    # 53:8600 53:8600/udp
    volumes: %w[
      /var/lib/consul:/data
      /etc/consul:/config
    ],
    restart_policy: 'always',
    helper_recipe: 'machine::consul'
  },

  swarm: {
    restart_policy: 'always',
    command: <<-eos
      join --advertise #{node[:ipaddress]}:#{node[:machine][:engine][:port]}
      consul://#{node[:ipaddress]}:8500
    eos
  }
}
