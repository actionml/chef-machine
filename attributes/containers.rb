## Options of the core containers
#
include_attribute 'machine::default'

core_opts = Mash.new({
  volumes:  node['machine']['docker_passthrough_volumes'],
  hostname: node['hostname']
})


## -----  consul agent
default['machine']['containers']['consul'] = core_opts.merge({
  image: 'stackfeed/consul:0.7-agent',
  confdir: '/etc/consul',
  exposed_ports: %w(
    8300:8300
    8301:8301 8301:8301/udp
    8302:8302 8302:8302/udp
    8400:8400
    8500:8500
    53:8600 53:8600/udp
  ),
  registrator_ignore: true,

  # nomad requires --cap-add=SYS_ADMIN and --security-opt=apparmor:unconfined (for ubuntu)
  # but we can't have the former, so we go for privileged
  restart_policy: 'always'
})

default['machine']['containers']['consul']['volumes'] += %w(
  /var/lib/consul:/data
  /etc/consul:/config
)


## ----- registrator
default['machine']['containers']['registrator'] = {
  image: 'gliderlabs/registrator:v7',
  hostname: node['hostname'],
  flags: '',
  registrator_ignore: true,
  restart_policy: 'always'
}

default['machine']['containers']['registrator']['command'] = <<-eos
    -ip #{node[:ipaddress]} -ttl 10 -ttl-refresh 5 -resync 3
    #{node['machine']['containers']['registrator']['flags']} consul://#{node[:ipaddress]}:8500
eos

default['machine']['containers']['registrator']['volumes'] = %w(
  /var/run/docker.sock:/tmp/docker.sock
  /usr/bin/docker:/usr/bin/docker
)


## ----- nomad agent
default['machine']['containers']['nomad'] = core_opts.merge({
  image: 'stackfeed/nomad:0.4',
  confdir: '/etc/nomad',
  scriptsdir: '/etc/nomad/scripts',
  jobsdir: '/etc/nomad/jobs',
  exposed_ports: %w(
    4646:4646
    4747:4747
  ),
  registrator_ignore: true,
  restart_policy: 'always',
  privileged: true,
  manage_volumes: false
})

default['machine']['containers']['nomad']['volumes'] += %w(
  /var/lib/nomad:/data
  /etc/nomad:/config
)


## ----- swarm container
default['machine']['containers']['swarm'] = {
  image: 'swarm',
  registrator_ignore: true,
  restart_policy: 'always',
  command: <<-eos
    join --advertise #{node[:ipaddress]}:#{node[:machine][:engine][:port]}
    consul://#{node[:ipaddress]}:8500
  eos
}
