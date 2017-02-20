extend Machine::ResolvHelpers

# Write consul configuration
local_nameservers = resolvconf[:nameservers]

template 'consul.agent.json' do
  path "#{node['machine']['containers']['consul']['confdir']}/agent.json"
  source 'agent.json.erb'
  mode 0644
  variables(lazy {
    {
      start_join: node['machine']['consul_options']['start_join'],
      recursors: local_nameservers
    }
  })
  notifies :redeploy, 'docker_container[consul]', :immediately
end

# used by dependant cookbooks
execute 'reload consul-agent' do
  command 'docker kill -s HUP consul; true'
  action :nothing
end
