# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#

include_recipe "apt"
include_recipe "yum"
include_recipe "build-essential"
include_recipe "sudo"

case node['platform_family']
when "rhel", "fedora"
  include_recipe "yum"
else
  include_recipe "apt"
end

node.set['authorization']['sudo']['users'] = ["#{node['nodejs_app']['username']}"]

databag = Chef::EncryptedDataBagItem.load(node['deployment']['id'], node['deployment']['app_id'])
node.set['nodejs_app']['password'] = databag['nodejs_app']['password']
node.set['nodejs_app']['deploy_key'] = databag['nodejs_app']['deploy_key']

appUser = node['nodejs_app']['username']
appDir = node['nodejs_app']['destination']
homeDir = "/home/#{appUser}"

user appUser do
  password node['nodejs_app']['password']
  supports :manage_home => true
  shell "/bin/bash"
  home homeDir
end

directory appDir do
  owner appUser
  mode "755"
  recursive true
end

bash "create Node directories" do
  user appUser
  code <<-EOH
    sudo mkdir -p /usr/local/{share/man,bin,lib/node,include/node,lib/node_modules}
    sudo chown -R #{appUser} /usr/local/{share/man,bin,lib/node,include/node,lib/node_modules}
  EOH
end

include_recipe "nodejs"

if node["nodejs_app"]["git_repo"]
  include_recipe "nodejs_cookbook::nodejs_deploy"
else
  include_recipe "nodejs_cookbook::nodejs_stack"
end

include_recipe "nodejs_cookbook::firewall"
