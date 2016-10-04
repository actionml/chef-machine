#
# Choose docker storage driver and set attributes
#
include_recipe 'chef-sugar'

docker = version(Machine::Docker.version)
kernel = version(node['kernel']['release'].split('-').first)

## Decide if we can use overlay storage driver
#
if kernel.satisfies?('>= 4.0') && docker.satisfies?('>= 1.12')
  node.default['machine']['docker_engine']['storage_driver'] = 'overlay2'
elsif kernel.satisfies?('>= 3.18')
  node.default['machine']['docker_engine']['storage_driver'] = 'overlay'
end
