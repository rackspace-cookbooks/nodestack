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

require 'json'

case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum'
else
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt'
end

%w(chef-sugar nodejs nodejs::npm git build-essential platformstack::monitors platformstack::iptables nodestack::setcap
).each do |recipe|
  include_recipe recipe
end

node['nodestack']['apps_to_deploy'].each do |app_name| # each app loop

  app_config = node['nodestack']['apps'][app_name]

  # Cleanup multiple strings referring to
  # "#{app_config['app_dir']/current/foo"
  app_deploy_dir = "#{app_config['app_dir']}/current"

  encrypted_databag = Chef::EncryptedDataBagItem.load("#{app_name}_databag", 'config')
  encrypted_environment = encrypted_databag[node.chef_environment]

  # Setup User
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
    path "/home/#{app_name}/.ssh/config"
    mode 0700
    owner app_name
    group app_name
    variables(
      git_repo_domain: app_config['git_repo_domain']
    )
  end

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

  template app_name do
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

  # Setup Node environment
  %w(logs pids).each do |dir|
    directory "#{app_config['app_dir']}/#{dir}" do
      owner app_name
      group app_name
      recursive true
      mode 0755
      action :create
    end
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
    enable_submodules app_config['enable_submodules']
    deploy_key encrypted_environment['ssh_deployment_key']
    repository app_config['git_repo']
    revision app_config['git_rev']
  end

  template 'config.js' do
    path "#{app_deploy_dir}/config.js"
    source 'config.js.erb'
    owner app_name
    group app_name
    mode '0644'
    variables(
      config_js: encrypted_environment['config']
    )
    only_if { app_config['config_file'] }
  end

  # Install npm and dependencies
  nodejs_npm 'npm-install-retry' do
    retries 5
    retry_delay 60
    action :install
  end

  nodejs_npm app_name do
    path app_deploy_dir
    json true
    user app_name
    group app_name
    options app_config['npm_options']
    retries 5
    retry_delay 30
    only_if { ::File.exist?("#{ app_deploy_dir }/package.json") && app_config['npm'] }
  end

  nodejs_npm 'forever' do
    path app_config['app_dir']
    user app_name
    retries 5
    retry_delay 30
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

  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['env']['PORT']} -j ACCEPT",
                    100, "Allow nodejs traffic for #{app_name}") if app_config['env']['PORT']

end # end each app loop

# Add monitoring
include_recipe 'nodestack::cloud_monitoring' if node.deep_fetch('platformstack', 'cloud_monitoring', 'enabled')

# Add logrotate
include_recipe 'nodestack::logrotate'
