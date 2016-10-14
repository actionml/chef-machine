## Install chef production cookbooks
#

# we expect berkshelf to be allready in chef gems
berks_bin = "#{Gem.default_bindir}/berks"

execute 'install-prod-cookbooks' do
  cwd node[:machine][:chef_root]
  command "#{berks_bin} vendor cookbooks"
  action :run
end
