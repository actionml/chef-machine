#
# Cookbook Name:: machine
# Recipe:: default
#
# Copyright (C) 2016 ActionML
#
# All rights reserved - Do Not Redistribute
#

Chef::Recipe.send(:include, Machine::Docker::RecipeMixin)
include_recipe 'machine::docker_engine'

core_containers = node['machine']['core_containers']


## Pull core services containers
#
core_containers.each do |name, opts|
  # pull image
  docker_image opts[:image] do
    tag opts[:tag] || 'latest'
    action :pull_if_missing
  end

  # create directoris
  opts.keys.select {|k| k =~ /dir$/ }.each do |dir|
    directory "#{name}-#{dir}" do
      path opts[dir]
      mode 0755
    end
  end
end


## Write configs
#

# Write consul configuration
template 'consul.agent.json' do
  path "#{core_containers['consul']['confdir']}/agent.json"
  source 'agent.json.erb'
  mode 0640

  variables(lazy {
    {
      discovery_host: node['discovery']['host']
    }
  })

  notifies :redeploy, 'docker_container[consul]', :immediately
end

# Write nomad configuration
template 'nomad.conf.hcl' do
  path "#{core_containers['nomad']['confdir']}/nomad.conf.hcl"
  source "nomad.conf.hcl.erb"
  mode 0640
  variables(lazy {
    {
      datacenter: 'dc1',
      region: 'global',
      client: node['nomad']['client']
    }
  })

  helpers(Machine::Nomad::TemplateMixin)

  notifies :redeploy, 'docker_container[nomad]', :immediately
end


## Start core containers
#

# used by dependant cookbooks
execute 'reload consul-agent' do
  command 'docker kill -s HUP consul; true'
  action :nothing
end

# consul
opts = node['machine']['core_containers']['consul']
ignore_exposed = registrator_ignore_labels(opts[:exposed_ports])

docker_container 'consul' do
  repo opts[:image]
  tag opts[:tag] || 'latest'
  host_name node[:machine][:hostname] || node[:hostname]

  volumes opts[:volumes]

  # ports and labels
  port opts[:exposed_ports]

  labels ignore_exposed

  log_opts opts[:log_opts]
  restart_policy 'always'

  action opts[:action] || :run
end

# registrator
opts = node['machine']['core_containers']['registrator']
ignore_exposed = registrator_ignore_labels(opts[:exposed_ports])

docker_container 'registrator' do
  repo opts[:image]
  tag opts[:tag] || 'latest'
  host_name node[:machine][:hostname] || node[:hostname]

  # startup command, we bind to local consul agent
  command <<-eos
    -ip #{node[:ipaddress]} -ttl 10 -ttl-refresh 5 -resync 3
    #{opts[:flags]} consul://#{node[:ipaddress]}:8500
  eos

  volumes opts[:volumes]

  # ports and labels
  port opts[:exposed_ports]
  labels ignore_exposed

  log_opts opts[:log_opts]
  restart_policy 'always'

  action opts[:action] || :run
end

# nomad
opts = node['machine']['core_containers']['nomad']
ignore_exposed = registrator_ignore_labels(opts[:exposed_ports])

docker_container 'nomad' do
  repo opts[:image]
  tag opts[:tag] || 'latest'
  host_name node[:machine][:hostname] || node[:hostname]

  volumes opts[:volumes]

  # ports and labels
  port opts[:exposed_ports]
  labels ignore_exposed

  log_opts opts[:log_opts]
  restart_policy 'always'

  # nomad requires --cap-add=SYS_ADMIN and --security-opt=apparmor:unconfined (for ubuntu)
  # but we can't have the former, so go for privileged
  privileged true

  action opts[:action] || :run
end

# swarm
opts = node['machine']['core_containers']['swarm']
ignore_exposed = registrator_ignore_labels(opts[:exposed_ports])

docker_container 'swarm' do
  repo opts[:image]
  tag opts[:tag] || 'latest'
  host_name node[:machine][:hostname] || node[:hostname]

  # startup command, we point swarm to local consul agent
  command <<-eos
    join --advertise #{node[:ipaddress]}:#{node[:machine][:docker][:engine_port]}
    consul://#{node[:ipaddress]}:8500
  eos

  volumes opts[:volumes]

  # ports and labels
  port opts[:exposed_ports]
  labels ignore_exposed

  log_opts opts[:log_opts]
  restart_policy 'always'

  action opts[:action] || :run
end
