# Encoding: utf-8
#
# Cookbook Name:: phpstack
# Recipe:: nginx
#
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

stackname = 'nodestack'

include_recipe 'chef-sugar'

if rhel?
  include_recipe 'yum-epel'
  include_recipe 'yum-ius'
end

# Include the necessary recipes.
%w(
  apt
  platformstack::monitors
  platformstack::iptables
).each do |recipe|
  include_recipe recipe
end

# Pid is different on Ubuntu 14, causing nginx service to fail https://github.com/miketheman/nginx/issues/248
node.default['nginx']['pid'] = '/run/nginx.pid' if ubuntu_trusty?

# Install Nginx
include_recipe 'nginx'

# Properly disable default vhost on Rhel (https://github.com/miketheman/nginx/pull/230/files)
# FIXME: should be removed once the PR has been merged
if !node['nginx']['default_site_enabled'] && (node['platform_family'] == 'rhel' || node['platform_family'] == 'fedora')
  %w(default.conf example_ssl.conf).each do |config|
    file "/etc/nginx/conf.d/#{config}" do
      action :delete
    end
  end
end

# create generic config files in conf.d
directory "#{node['nginx']['dir']}/conf.d" do
  owner 'root'
  group 'root'
  mode  '0644'
end

unless node[stackname]['nginx']['confd'].nil?
  node[stackname]['nginx']['confd'].each do |config, options|
    template "additional config file #{config}" do
      cookbook options['cookbook']
      source options['template']
      path "#{node['nginx']['dir']}/conf.d/#{config}.conf"
      owner 'root'
      group 'root'
      mode '0644'
      variables(options['variables'])
      notifies :reload, 'service[nginx]'
    end
  end
end

# Create the sites.
listen_ports = []
node[stackname]['nginx']['sites'].each do |port, sites|
  listen_ports |= [port]
  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{port} -j ACCEPT", 100, 'Allow access to nginx')
  sites.each do |site_name, site_opts|
    # site set up
    template "#{site_name}-#{port}" do
      cookbook site_opts['cookbook']
      source site_opts['template']
      path "#{node['nginx']['dir']}/sites-available/#{site_name}-#{port}.conf"
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        site_opts['variables'].merge('port' => port)
      )
      notifies :reload, 'service[nginx]'
    end
    nginx_site "#{site_name}-#{port}.conf" do
      enable true
      notifies :reload, 'service[nginx]'
    end

    Chef::Log.warn("No monitor will be created for nginx site #{site_name}-#{port}. Missing server_name variable") if site_opts['variables']['server_name'].nil?

    # cloud monitoring setup
    template "http-monitor-#{site_opts['variables']['server_name']}-#{port}" do
      cookbook stackname
      source 'monitoring-remote-http.yaml.erb'
      path "/etc/rackspace-monitoring-agent.conf.d/#{site_opts['variables']['server_name']}-#{port}-http-monitor.yaml"
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        http_port: port,
        server_name: site_opts['variables']['server_name']
      )
      notifies 'restart', 'service[rackspace-monitoring-agent]', 'delayed'
      action :create
      only_if { node.deep_fetch('platformstack', 'cloud_monitoring', 'enabled') }
    end
  end
end

node.default['nginx']['listen_ports'] = listen_ports
