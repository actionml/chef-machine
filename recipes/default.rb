#
# Cookbook Name:: machine
# Recipe:: default
#
# Copyright (C) 2016 ActionML
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'machine::docker_engine'
include_recipe 'machine::core_containers'
include_recipe 'machine::consul_kv'

if ::File.readable?(::File.join(node[:machine][:chef_root], 'chef/Berksfile'))
  include_recipe 'machine::cookbooks'
end
