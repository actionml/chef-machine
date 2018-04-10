#
# Cookbook Name:: machine
# Recipe:: consul
#
# Copyright (C) 2016-2018 ActionML
#
# All rights reserved - Do Not Redistribute
#

extend Machine::NetworkHelpers

# Provide consul cookbook with specific configuration (if it's required...)
node.default['consul']['service']['config_dir'] =
  node['machine']['containers']['consul']['confdir']

node.default['consul']['service_user'] = 'root'
node.default['consul']['service_group'] = 'root'

# install ec2-metadata gem
chef_gem 'ec2-metadata' do
  compile_time true if respond_to?(:compile_time)
end
require 'ec2_metadata'

## Prepare node meta for consul
#
node_meta = {
  class:  node['machine']['node_class'] || 'node',
  instance_id: Ec2Metadata['instance_id']
}

## Write consul configuration
#
# merge with failsafe defaults in case machine's resolve.conf is flawed or empty
failsafe = node['machine']['consul_options']['resolv_failsafe']
nameservers = failsafe.merge(resolvconf)['nameservers']
confdir = node['machine']['containers']['consul']['confdir']

# create consult confdir
directory confdir do
  recursive true
  action :create
end

# create agent.json
template 'consul.agent.json' do
  path "#{confdir}/agent.json"
  source 'agent.json.erb'
  mode 0_644
  variables(
    start_join: node['machine']['consul_options']['start_join'],
    leave_on_terminate: node['machine']['consul_options']['leave_on_terminate'],
    recursors: nameservers,
    node_meta: JSON.pretty_generate(node_meta).gsub(/^/, '  ').strip
  )
end

# used by dependant cookbooks
execute 'reload consul-agent' do
  command 'docker kill -s HUP consul; true'
  action :nothing
end

## Create a fake "node_meta" service used for consul node lookup queries!
#
consul_definition 'node_meta' do
  type 'service'

  parameters(
    tags: (
      node_meta.map { |k, v| "#{k}:#{v}" } +
        Array(node['machine']['node_tags'] || [])
    )
  )

  notifies :run, 'execute[reload consul-agent]'
  action :create
end
