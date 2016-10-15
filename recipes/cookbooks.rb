## Install chef production cookbooks
#
require 'tmpdir'

::Chef::Recipe.send(:include, AML::RecipeHelpers)


# we expect berkshelf to be allready in chef gems
berks_bin = "#{Gem.default_bindir}/berks"
deploy_key = "/root/.ssh/#{aml.project[:key_name]}-deploy"

# exit if no deploy-key
return if !File.exist?(deploy_key)

# Add deploy key into ssh-agent and get env.
ssh_agent.add_identity(deploy_key)
ssh_agent_env = ssh_agent.env

# Install private cookbooks
node[:machine][:chef_cookbooks].each do |giturl, opts|
  repo = File.basename(giturl).gsub(/.git$/, '')

  gitdir = Dir::Tmpname.make_tmpname('/tmp/', nil)
  opts = Mash.new({
    ref: 'master',
    depth: 1,
  }).update(opts)

  # fetch private cookbook into temp directory
  git gitdir do
    repository giturl
    reference opts[:ref]
    depth opts[:depth].to_i

    environment ssh_agent_env || {}
  end

  # install cookbook using berks
  execute "berks-#{repo}" do
    environment ssh_agent_env || {}
    cwd gitdir
    command "#{berks_bin} vendor #{node[:machine][:chef_root]}/cookbooks"

    action :run
  end

  directory gitdir do
    recursive true
    action :delete
  end
end
