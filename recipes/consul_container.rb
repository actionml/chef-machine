require 'ec2_metadata'

extend Machine::NetworkHelpers


# Set consul cookbook specific for our configuration
node.default['consul']['service']['config_dir'] = node['machine']['containers']['consul']['confdir']
node.default['consul']['service_user'] = 'root'
node.default['consul']['service_group'] = 'root'


## Prepare node meta for consul
#

node_meta = {
  class:  node['machine']['node_class'] || 'node',
  instance_id: Ec2Metadata['instance_id'] 
}

node_meta = node_meta.inject({}) do |acum, (k, v)|
              acum[k] = v if not v.nil?
              acum
            end

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
      start_join:
          node['machine']['consul_options']['start_join'],
      leave_on_terminate:
          node['machine']['consul_options']['leave_on_terminate'],
      recursors: nameservers,
      node_meta:
          JSON.pretty_generate(node_meta).gsub(/^/, '  ').strip
    }
  })
  notifies :redeploy, 'docker_container[consul]', :immediately
end

# used by dependant cookbooks
execute 'reload consul-agent' do
  command 'docker kill -s HUP consul; true'
  action :nothing
end


## Create "node" helper service to hold additional info which
#  can be retrieved at run-time

consul_definition "_node" do
  type 'service'

  parameters(
    parameters.merge(
      tags: node['machine']['node_tags'] +
        node_meta.map {|k, v| "#{k}:#{v}"}
    )
  )

  notifies :run, 'execute[reload consul-agent]'
  action :create
end
