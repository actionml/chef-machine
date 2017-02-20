include_recipe 'chef-sugar'


## Choose docker storage driver
#
docker = version(Machine::Docker.version)
kernel = version(node['kernel']['release'].split('-').first)

if kernel.satisfies?('>= 4.0') && docker.satisfies?('>= 1.12')
  node.default['machine']['engine']['storage_driver'] = 'overlay2'
elsif kernel.satisfies?('>= 3.18')
  node.default['machine']['engine']['storage_driver'] = 'overlay'
end


## Evalute where docker daemon listens
#
engine = node['machine']['engine']
if engine['bind_address']
  node.default['machine']['engine']['listens'] << "tcp://#{engine['bind_address']}:#{engine['port']}"
end
