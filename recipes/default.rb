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

node.set['authorization']['sudo']['users'] = ["#{node['nodestack']['app_user']}"]

#databag = Chef::EncryptedDataBagItem.load(node['deployment']['id'], node['deployment']['app_id'])
#node.set['nodestack']['password'] = databag['nodestack']['password']
#node.set['nodestack']['deploy_key'] = databag['nodestack']['deploy_key']

app_user = node['nodestack']['app_user']
app_dir = node['nodestack']['destination']
home_dir = "/home/#{app_user}"

user app_user do
  #password node['nodestack']['password']
  supports :manage_home => true
  shell "/bin/bash"
  home home_dir
end

directory app_dir do
  owner app_user
  mode "755"
  recursive true
end

bash "create Node directories" do
  user app_user
  code <<-EOH
    sudo mkdir -p /usr/local/{share/man,bin,lib/node,include/node,lib/node_modules}
    sudo chown -R #{app_user} /usr/local/{share/man,bin,lib/node,include/node,lib/node_modules}
  EOH
end

include_recipe "nodejs"

if node["nodestack"]["git_repo"]
  include_recipe "nodestack::nodejs_deploy"
else
  include_recipe "nodestack::nodejs_stack"
end

include_recipe 'platformstack::iptables'
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['nodestack']['http_port']} -j ACCEPT", 100, 'Allow nodejs http traffic')
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['nodestack']['https_port']} -j ACCEPT", 100, 'Allow nodejs https traffic')
