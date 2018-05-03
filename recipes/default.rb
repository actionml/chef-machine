#
# Cookbook Name:: machine
# Recipe:: default
#
# Copyright (C) 2016-2018 ActionML
#
# All rights reserved - Do Not Redistribute
#

# Add recipe helpers mixin
extend Machine::RecipeHelpers

# setup_docker_engine (returns machine.engine attribute)
engine = setup_docker_engine

# update machine.containers with calculated data
setup_containers

## ------
#  Docker Engine service
#
docker_service_manager 'default' do
  host engine['listens']
  graph engine['data_dir']
  labels engine['labels']
  storage_driver engine['storage_driver']

  action :start
end

## -----
#  Bootstrap containers provided with the bootstrap_containers list
#
node['machine']['bootstrap_containers'].each do |container|
  spec = node['machine']['containers'][container] || {}
  image, tag = get_image_tag(spec[:image] || container)

  # execute specific container logic if recipe is available
  spec[:helper_recipe] && include_recipe(spec[:helper_recipe])

  # pull docker image
  docker_image image do
    tag tag
    action :pull_if_missing
  end

  # create host directories for container volumes
  create_missing_volumedirs(container)

  # start a service container
  docker_container container do
    repo image
    tag  tag
    labels Array(spec[:labels])
    volumes Array(spec[:volumes])
    log_opts Array(spec[:log_opts])
    port Array(spec[:exposed_ports])

    command spec[:command] if spec[:command]
    host_name spec[:hostname] if spec[:hostname]
    network_mode spec[:network_mode] if spec[:network_mode]
    privileged spec[:privileged] if spec[:privileged]
    restart_policy spec[:restart_policy] if spec[:restart_policy]

    action((spec[:action] || :run).to_sym)
  end
end
