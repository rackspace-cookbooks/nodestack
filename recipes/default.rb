# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#

include_recipe 'apt'
include_recipe 'yum'

node.set['build-essential']['compile_time'] = true
include_recipe 'build-essential'

include_recipe 'git'

case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum'
  include_recipe 'nodejs'
else
  include_recipe 'apt'
  include_recipe 'nodejs::install_from_binary'
end

include_recipe 'nodestack::application_nodejs'

include_recipe 'platformstack::iptables'
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['nodestack']['listening_port']} -j ACCEPT", 100, 'Allow nodejs http traffic')
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['nodestack']['https_port']} -j ACCEPT", 100, 'Allow nodejs https traffic')
