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

node['nodestack']['apps_to_deploy'].each do |app_name| # each app loop
  app_config = node['nodestack']['apps'][app_name]

  # Setup monitor
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
      body: app_config['monitoring']['body']
    )
    notifies 'restart', 'service[rackspace-monitoring-agent]', 'delayed'
    action 'create'
  end
end
