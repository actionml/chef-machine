#
# Cookbook Name:: machine
# Recipe:: docker_engine
#
# Copyright (C) 2016 ActionML
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'machine::_docker_settings'
engine = node['machine']['engine']

## ReConfigure the "default" docker service and start
#
docker_service_manager 'default' do
  host engine['listens']
  graph engine['data_dir']
  labels engine['labels']

  # Use specified driver or default chosen by Docker
  storage_driver(engine['storage_driver']) if engine['storage_driver']
  action :start
end
