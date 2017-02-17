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
hostdir_resources = []


node['machine']['bootstrap_containers'].each do |container|
  next if node['machine']['ignore_containers'].include?(container)

  opts = node['machine']['containers'][container]
  image = opts[:image].split(':')[0]
  tag = opts[:image].split(':')[1] || 'latest'
  volumes = opts[:volumes] || []

  # compose the default options
  opts = node['machine']['container_default_options'].merge(opts)
  
  # create host volume directories
  volumes.each do |volume|
    dirpath = volume.split(':').first
    next if hostdir_resources.include?(dirpath)

    directory dirpath do
      recursive true
      not_if { ::File.exist?(dirpath) }
      action :create
    end

    hostdir_resources << dirpath
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

    action opts[:action] || :run
  end
end
