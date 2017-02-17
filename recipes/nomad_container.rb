
# Write nomad configuration
template 'nomad.conf.hcl' do
  path "#{node['machine']['containers']['nomad']['confdir']}/nomad.conf.hcl"
  source "nomad.conf.hcl.erb"
  mode 0644
  variables(lazy {
    {
      datacenter: 'dc1',
      region: 'global',
      client: node['machine']['nomad_options']['client']
    }
  })

  helpers(Machine::Nomad::TemplateMixin)
  notifies :redeploy, 'docker_container[nomad]', :immediately
end
