
include_recipe 'machine::_docker_storage_driver'
engine = node['machine']['docker_engine']

## ReConfigure default docker service and start
#
docker_service_manager 'default' do
  host engine['bind']
  graph engine['data_dir']
  labels engine['labels']

  # Use specified driver or default chosen by Docker
  storage_driver(engine['storage_driver']) if engine['storage_driver']

  action :start
end
