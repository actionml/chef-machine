## Install chef production cookbooks
#
::Chef::Recipe.send(:include, AML::RecipeHelpers)


# we expect berkshelf to be allready in chef gems
berks_bin = "#{Gem.default_bindir}/berks"
deploy_key = "/root/.ssh/deploy-#{aml.project[:key_name]}"

# Add deploy key into ssh-agent and get env.
if ::File.exist?(deploy_key)
  ssh_agent.add_identity(deploy_key)
  ssh_agent_env = ssh_agent.env
end

## Install production cookbooks (with ssh env provided).
#
execute 'install-prod-cookbooks' do
  environment ssh_agent_env || {}
  cwd node[:machine][:chef_root]
  command "#{berks_bin} vendor cookbooks"

  action :run
end
