require 'ec2_metadata'

extend Machine::NetworkHelpers

# Set consul cookbook specific for our configuration
node.default['consul']['service']['config_dir'] = node['machine']['containers']['consul']['confdir']
node.default['consul']['service_user'] = 'root'
node.default['consul']['service_group'] = 'root'


## Write consul configuration
#

# merge with failsafe defaults in case machine's resolve.conf is flawed or empty
failsafe = node['machine']['consul_options']['resolv_failsafe']
nameservers = failsafe.merge(resolvconf)['nameservers']

template 'consul.agent.json' do
  path "#{node['machine']['containers']['consul']['confdir']}/agent.json"
  source 'agent.json.erb'
  mode 0644
  variables(lazy {
    {
      start_join: node['machine']['consul_options']['start_join'],
      recursors: nameservers
    }
  })
  notifies :redeploy, 'docker_container[consul]', :immediately
end

# used by dependant cookbooks
execute 'reload consul-agent' do
  command 'docker kill -s HUP consul; true'
  action :nothing
end


## Register machine node_class
#

node_class = node['machine']['node_class']
node_address = host_addresses[node['machine']['network_number']]


## Use node id based on cloud provider instance id
#
parameters =  case node['cloud']['provider']
              when 'ec2'
                {
                  id: Ec2Metadata['instance_id']
                }
              else
                {}
              end


# create service defintion in consul
consul_definition "node-#{node_class}" do
  type 'service'

  parameters(
    parameters.merge(
      address: node_address,
      tags: node['machine']['node_tags']
    )
  )

  not_if { node_class.empty? }

  notifies :run, 'execute[reload consul-agent]'
  action :create
end
