# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum'
else
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt'
end

node.set['build-essential']['compile_time'] = true
include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'nodejs::nodejs_from_source'
include_recipe 'nodejs::npm_from_source'
include_recipe 'nodestack::application_nodejs'

include_recipe 'platformstack::iptables'

node['nodestack']['apps'].each_pair do |_app_name, app_config| # each app loop
  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['http_port']} -j ACCEPT", 100, 'Allow nodejs http traffic')
  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['https_port']} -j ACCEPT", 100, 'Allow nodejs https traffic')
end
