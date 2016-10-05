
# Docker access volumes, those used to access docker from inside a container
default['machine']['docker'] = {
  engine_port: 2375,
  access_volumes: %w(
    /var/run/docker.sock:/var/run/docker.sock
    /usr/bin/docker:/usr/bin/docker
  )
}

# Docker engine options
default['machine']['docker_engine'] = {
  data_dir: '/var/lib/docker',
  bind: %W(
            unix:///var/run/docker.sock
            tcp://0.0.0.0:#{node[:machine][:docker][:engine_port]}
          ),
  log_opts: %w(max-size=50m max-file=5),
  labels: []
}

## Consul default address and a map that should be populated into consul.
#
default['consul'] = {
  address: '127.0.0.1:8500',
  resolv_defaults: {
    nameservers: %W(8.8.4.4 8.8.8.8)
  },
  start_join: [],
  kv: {}
}
