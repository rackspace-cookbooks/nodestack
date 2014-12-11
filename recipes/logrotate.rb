# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: logrotate
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
include_recipe 'logrotate::default'

node['nodestack']['apps'].each do |app| # each app loop
  app_name = app[0]
  app_config = node['nodestack']['apps'][app_name]

  logfile = "#{app_config['app_dir']}/logs/forever.log"
  outfile = "#{app_config['app_dir']}/logs/forever.out"
  errfile = "#{app_config['app_dir']}/logs/forever.err"

  logrotate_app app_name do
    cookbook 'logrotate'
    frequency 'daily'
    path [logfile, outfile, errfile]
    template_mode '0644'
    create "644 #{app_name} #{app_name}"
    rotate 10
    compress 'True'
  end
end
