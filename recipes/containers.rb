#
# Cookbook Name:: machine
# Recipe:: containers
#
# Copyright (C) 2016 ActionML
#
# All rights reserved - Do Not Redistribute
#

# Recipe cycles through the list of containers to bootstrap, excluding
# those to ignore. It's task evaluate general options then pull and start.
#

extend Machine::DockerHelpers


## Ordered hash of containers to bootstrap
#
bootstrap_containers =
node['machine']['bootstrap_containers'].inject(Mash.new) do |mash, container|
  node['machine']['ignore_containers'].include?(container) or
    mash[container] = node['machine']['containers'][container]
  mash
end


## Manage host directories for the volumes of bootstrap containers
#
host_paths =
bootstrap_containers.map do |_, opts|
  if opts['manage_volumes'] != false
    (opts['volumes'] || []).map { |v| v.partition(':').first }
  else
    []
  end
end.flatten.uniq

host_paths.each do |dirpath|
  directory dirpath do
    recursive true

    # host path might exist and be a file
    not_if { ::File.exist?(dirpath) }
    action :create
  end
end


## Create containers
#
bootstrap_containers.each do |container, opts|

  image = opts[:image].split(':')[0]
  tag = opts[:image].split(':')[1] || 'latest'
  volumes = opts[:volumes] || []

  # compose the default options
  opts = node['machine']['container_default_options'].merge(opts)
  
  # pull image if missing
  docker_image image do
    tag tag || 'latest'
    action (opts[:pull_action] || :pull_if_missing).to_sym
  end

  # execute specific container logic if recipe is available
  begin
    include_recipe "machine::#{container}_container"
  rescue Chef::Exceptions::RecipeNotFound
  end

  # exposed ports of a container should be ignored by registrator and lables
  registrator_ignore = registrator_ignore_labels(opts[:exposed_ports]) if opts[:registrator_ignore]
  labels = Array(opts[:lables]) + Array(registrator_ignore)

  # start a service container
  docker_container container do
    repo image
    tag tag
    labels labels
    volumes volumes

    command opts[:command] if opts[:command]
    host_name opts[:hostname] if opts[:hostname]
    log_opts opts[:log_opts] if opts[:log_opts]
    port opts[:exposed_ports] if opts[:exposed_ports]
    privileged opts[:privileged] if opts[:privileged]
    restart_policy opts[:restart_policy] if opts[:log_opts]

    action (opts[:action] || :run).to_sym
  end
end
