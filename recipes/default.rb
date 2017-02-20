#
# Cookbook Name:: machine
# Recipe:: default
#
# Copyright (C) 2016 ActionML
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'machine::docker_engine'
include_recipe 'machine::containers'

# if ::File.readable?(::File.join(node[:machine][:chef_root], 'Berksfile'))
#   include_recipe 'machine::cookbooks'
# end
