#
# Cookbook Name:: machine
# Recipe:: docker_engine
#
# Copyright (C) 2016-2018 ActionML
#
# All rights reserved - Do Not Redistribute
#

# setup_docker_engine returns node['machine']['engine']
engine = setup_docker_engine

# configure the "default" docker service and start
docker_service_manager 'default' do
  host engine['listens']
  graph engine['data_dir']
  labels engine['labels']
  storage_driver engine['storage_driver']

  # restart, because strangely driver has been picked up only after manual service restart
  action :start
end
