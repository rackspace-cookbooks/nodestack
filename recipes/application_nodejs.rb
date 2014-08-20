# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: default
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

include_recipe 'chef-sugar'

case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum'
else
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt'
end

node.set['build-essential']['compile_time'] = 'source'
%w(nodejs nodejs::npm git build-essential platformstack::monitors platformstack::iptables apt nodestack::setcap).each do |recipe|
  include_recipe recipe
end

node['nodestack']['apps_to_deploy'].each do |app_name| # each app loop

  app_config = node['nodestack']['apps'][app_name]

  encrypted_databag = Chef::EncryptedDataBagItem.load("#{app_name}_databag", 'config')
  encrypted_environment = encrypted_databag[node.chef_environment]

  user app_name do
    supports manage_home: true
    shell '/bin/bash'
    home "/home/#{app_name}"
  end

  sudo app_name do
    user app_name
    nopasswd true
    commands ["/sbin/restart #{app_name}", "/sbin/start #{app_name}", "/sbin/stop #{app_name}"]
  end

  directory "/home/#{app_name}/.npm" do
    owner app_name
    group app_name
    mode 0755
    action :create
  end

  directory "/home/#{app_name}/.ssh" do
    owner app_name
    group app_name
    mode 0700
    action :create
  end

  template 'ssh config with strict host check disabled' do
    source 'ssh_config.erb'
    path '/home/' + app_name + '/.ssh/config'
    mode 0700
    owner app_name
    group app_name
    variables(
      git_repo_domain: app_config['git_repo_domain']
    )
  end

  template "#{app_name}.conf" do
    path "/etc/init/#{app_name}.conf"
    source 'nodejs.upstart.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      user: app_name,
      binary_path: node['nodestack']['binary_path'],
      app_dir: app_config['app_dir'],
      entry: 'server.js',
      app_name: app_name,
      env: app_config['env']
    )
    only_if { platform_family?('debian') }
    notifies 'restart', "service[#{app_name}]", 'delayed'
  end

  template app_name do
    path "/etc/init.d/#{app_name}"
    source 'nodejs.initd.erb'
    owner 'root'
    group 'root'
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
    only_if { platform_family?('rhel') }
    notifies 'restart', "service[#{app_name}]", 'delayed'
  end

  directory "#{app_config['app_dir']}/logs" do
    owner app_name
    group app_name
    recursive true
    mode 0755
    action :create
  end

  directory "#{app_config['app_dir']}/pids" do
    owner app_name
    group app_name
    mode 0755
    action :create
  end

  app_config['env'].each_pair do |variable, value|
    magic_shell_environment variable do
      value value
      notifies :restart, "service[#{app_name}]", :delayed
    end
  end

  application 'nodejs application' do
    path app_config['app_dir']
    owner app_name
    group app_name
    deploy_key encrypted_environment['ssh_deployment_key']
    repository app_config['git_repo']
    revision app_config['git_rev']
  end

  template 'config.js' do
    path app_config['app_dir'] + '/current/config.js'
    source 'config.js.erb'
    owner app_name
    group app_name
    mode '0644'
    variables(
      config_js: encrypted_environment['config']
    )
    only_if { app_config['config_file'] }
  end

  execute 'npm install retry' do
    command 'npm -g install npm-install-retry'
  end

  execute 'Install npm packages from package.json' do
    cwd "#{app_config['app_dir']}/current"
    command 'npm-install-retry --wait 60 --attempts 5'
    environment 'HOME' => "/home/#{ app_name }", 'USER' => app_name
    user app_name
    group app_name
    only_if { ::File.exist?("#{ app_config['app_dir'] }/current/package.json") && app_config['npm'] }
  end

  execute 'npm install forever' do
    cwd app_config['app_dir']
    user app_name
    command 'npm install forever'
    environment 'HOME' => "/home/#{ app_name }"
  end

  template 'server.js for forever' do
    path "#{app_config['app_dir']}/server.js"
    source 'forever-server.js.erb'
    owner app_name
    group app_name
    mode '0644'
    variables(
      app_dir: app_config['app_dir'],
      ignore_patterns: node['nodestack']['forever']['watch_ignore_patterns'],
      entry_point: app_config['entry_point']
  )
    notifies 'restart', "service[#{app_name}]", 'delayed'
  end

  template "http-monitor-#{app_name}" do
    cookbook 'nodestack'
    source 'monitoring-remote-http.yaml.erb'
    path "/etc/rackspace-monitoring-agent.conf.d/#{app_name}-http-monitor.yaml"
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      port: app_config['env']['PORT'],
      app_name: app_name,
      body: app_config['monitoring']['body'],
    )
    notifies 'restart', 'service[rackspace-monitoring-agent]', 'delayed'
    action 'create'
    only_if { node.deep_fetch('platformstack', 'cloud_monitoring', 'enabled') }
  end

  service app_name do
    case node['platform']
    when 'ubuntu'
      provider Chef::Provider::Service::Upstart
      restart_command "stop #{app_name} && start #{app_name}"
    end
    action [:enable, :start]
  end

  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['env']['PORT']} -j ACCEPT",
                    100, "Allow nodejs traffic for #{app_name}")

end # end each app loop
