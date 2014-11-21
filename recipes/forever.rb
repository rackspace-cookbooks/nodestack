# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: forever
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
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

node['nodestack']['apps'].each do |app| # each app loop

  app_name = app[0]
  app_config = node['nodestack']['apps'][app_name]

  # Setup Service
  # Service resources vary by platform
  case node['platform_family']
  when 'debian'
    init_path = "/etc/init/#{app_name}.conf"
    init_source = 'nodejs.upstart.conf.erb'
  when 'rhel'
    # RHEL/CentOS has a new service system in 7+
    if node['platform_version'].to_f < 7.0
      init_path = "/etc/init.d/#{app_name}"
      init_source = 'nodejs.initd.erb'
    else
      init_path = "/etc/systemd/system/#{app_name}.service"
      init_source = 'nodejs.service.erb'
    end
  end

  template init_path do
    path init_path
    source init_source
    mode '0755'
    variables(
      user: app_name,
      app_name: app_name,
      binary_path: node['nodestack']['binary_path'],
      app_dir: app_config['app_dir'],
      entry: 'server.js',
      app_name: app_name,
      env: app_config['env']
    )
    notifies 'reload', "service[#{app_name}]", 'immediately'
    notifies 'restart', "service[#{app_name}]", 'delayed'
  end

  template 'server.js for forever' do
    path "#{app_config['app_dir']}/server.js"
    source 'forever-server.js.erb'
    owner app_name
    group app_name
    mode '0644'
    variables(
      app_dir: app_config['app_dir'],
      app_options: app_config['app_options'],
      ignore_patterns: node['nodestack']['forever']['watch_ignore_patterns'],
      entry_point: app_config['entry_point']
    )
    notifies 'restart', "service[#{app_name}]", 'delayed'
  end

  nodejs_npm 'forever' do
    path app_config['app_dir']
    version '0.11.1'
    user app_name
    retries 5
    retry_delay 30
  end

  service app_name do
    case node['platform']
    when 'ubuntu'
      provider Chef::Provider::Service::Upstart
      restart_command "/sbin/initctl stop #{app_name} && /sbin/initctl start #{app_name}"
      init_command "/etc/init/#{app_name}"
    when 'redhat', 'centos'
      if node['init_package'] == 'systemd'
        provider Chef::Provider::Service::Systemd
        reload_command 'systemctl daemon-reload'
      end
    end
    action ['enable', 'start']
  end

end
