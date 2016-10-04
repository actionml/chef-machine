include_attribute 'machine::default'

engine_opts = node['machine']['docker_engine']
docker_opts = node['machine']['docker']

## Consul agent container configuration
#
default['machine']['core_containers']['consul'] = {
  confdir: '/etc/consul',
  image: 'stackfeed/consul',
  tag: '0.6-agent',
  log_opts: engine_opts['log_opts'],
  exposed_ports: %W(
    #{node[:ipaddress]}:8300:8300
    #{node[:ipaddress]}:8301:8301
    #{node[:ipaddress]}:8301:8301/udp
    #{node[:ipaddress]}:8302:8302
    #{node[:ipaddress]}:8302:8302/udp
    #{node[:ipaddress]}:8400:8400
    #{node[:ipaddress]}:8500:8500
    #{node[:ipaddress]}:53:8600/udp
    #{node[:ipaddress]}:53:8600
  ),
  volumes: %w(
    /var/lib/consul:/data
    /etc/consul:/config
  ) + docker_opts['access_volumes']
}

## Registrator container configuration
#
default['machine']['core_containers']['registrator'] = {
  image: 'gliderlabs/registrator',
  tag: 'v7',
  flags: '',
  log_opts: engine_opts['log_opts'],
  volumes: %w(/var/run/docker.sock:/tmp/docker.sock
              /usr/bin/docker:/usr/bin/docker)
}

## Nomad container configuration
#
default['machine']['core_containers']['nomad'] = {
  confdir: '/etc/nomad',
  scriptsdir: '/etc/nomad/scripts',
  jobsdir: '/etc/nomad/jobs',
  image: 'makeomatic/nomad',
  tag: '0.4',
  log_opts: engine_opts['log_opts'],
  exposed_ports: %W(
    #{node[:ipaddress]}:4646:4646
    #{node[:ipaddress]}:4747:4747
  ),
  volumes: %w(
    /var/lib/nomad:/data
    /etc/nomad:/config
  ) + docker_opts['access_volumes']
}

## Swarm container configuration
#
default['machine']['core_containers']['swarm'] = {
  image: 'swarm',
  log_opts: engine_opts['log_opts']
}
