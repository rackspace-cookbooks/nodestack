# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: mysql_base
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# run apt-get update to clear cache issues
include_recipe 'apt' if node.platform_family?('debian')

include_recipe 'chef-sugar'
include_recipe 'database::mysql'
include_recipe 'platformstack::monitors'
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe 'mysql::server'

include_recipe 'mysql-multi'

connection_info = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['server_root_password']
}

# add holland user (if holland is enabled)
mysql_database_user 'holland' do
  connection connection_info
  password node['holland']['password']
  host 'localhost'
  privileges [:usage, :select, :'lock tables', :'show view', :reload, :super, :'replication client']
  retries 2
  retry_delay 2
  action [:create, :grant]
  only_if { node.deep_fetch('holland', 'enabled') }
end

node.set_unless['nodestack']['cloud_monitoring']['agent_mysql']['password'] = secure_password

mysql_database_user node['nodestack']['cloud_monitoring']['agent_mysql']['user'] do
  connection connection_info
  password node['nodestack']['cloud_monitoring']['agent_mysql']['password']
  action 'create'
end

template 'mysql-monitor' do
  cookbook 'nodestack'
  source 'monitoring-agent-mysql.yaml.erb'
  path '/etc/rackspace-monitoring-agent.conf.d/agent-mysql-monitor.yaml'
  owner 'root'
  group 'root'
  mode '00600'
  notifies 'restart', 'service[rackspace-monitoring-agent]', 'delayed'
  action 'create'
end

node['nodestack']['apps'].each_pair do |app_name, app_config| # each app loop

  if Chef::Config[:solo]
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
    app_nodes = []
  else
    app_nodes = search(
      :node, 
      "recipes:nodestack\\:\\:application_nodejs AND chef_environment:#{node.chef_environment}"
    )
  end

  app_nodes.each do |app_node|
    mysql_database_user app_name do
      connection connection_info
      password app_config['mysql_app_user_password']
      host best_ip_for(app_node)
      database_name app_name
      privileges %w(create select update insert)
      retries 2
      retry_delay 2
      action %w(create grant)
    end
  end

  # always do a localhost grant (fix for no search results on all-in-1 stack)
  mysql_database_user app_name do
    connection connection_info
    password app_config['mysql_app_user_password']
    host '127.0.0.1'
    database_name app_name
    privileges %w(create select update insert)
    retries 2
    retry_delay 2
    action %w(create grant)
  end
end

# allow the app nodes to connect
search_add_iptables_rules(
  "recipes:nodestack\\:\\:application_nodejs AND chef_environment:#{node.chef_environment}",
  'INPUT',
  '-p tcp --dport 3306 -j ACCEPT',
  9998,
  'allow app nodes to connect'
)
