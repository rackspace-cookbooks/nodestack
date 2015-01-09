# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: demo
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

# There's no web server setup as a reverse proxy in the demo, so we still
# want to use setcap to be able to bind low ports.
node.set['nodestack']['bind_low_ports'] = true
node.set['nodestack']['apps']['my_nodejs_app']['app_dir'] = '/var/app'
node.set['nodestack']['apps']['my_nodejs_app']['app_options'] = []
node.set['nodestack']['apps']['my_nodejs_app']['git_repo'] = 'git@github.com:marcoamorales/node-hello-world.git'
node.set['nodestack']['apps']['my_nodejs_app']['git_rev'] = 'HEAD'
node.set['nodestack']['apps']['my_nodejs_app']['git_repo_domain'] = 'github.com'
node.set['nodestack']['apps']['my_nodejs_app']['enable_submodules'] = false
node.set['nodestack']['apps']['my_nodejs_app']['entry_point'] = 'app.js'
node.set['nodestack']['apps']['my_nodejs_app']['npm'] = true
node.set['nodestack']['apps']['my_nodejs_app']['config_file'] = true
node.set['nodestack']['apps']['my_nodejs_app']['env']['PORT'] = '80'
node.set['nodestack']['apps']['my_nodejs_app']['env']['MONGO_PORT'] = '27017'
node.set['nodestack']['apps']['my_nodejs_app']['monitoring']['body'] = 'Hello World!'
node.set['nodestack']['apps']['my_nodejs_app']['npm_options'] = ['--production']
node.set['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink'] = 'test_before_symlink.rb'
node.set['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink_template'] = 'before_symlink_test.rb.erb'
node.set['nodestack']['apps']['my_nodejs_app']['deployment']['strategy'] = 'forever'
node.set['nodestack']['cookbook'] = 'nodestack'

node.set_unless['platformstack']['cloud_monitoring']['remote_http']['name'] = []
node.set['platformstack']['cloud_monitoring']['remote_http']['name'].push('my_nodejs_app')
node.set['platformstack']['cloud_monitoring']['remote_http']['my_nodejs_app']['source'] = 'monitoring-remote-http.yaml.erb'
node.set['platformstack']['cloud_monitoring']['remote_http']['my_nodejs_app']['cookbook'] = 'platformstack'
node.set['platformstack']['cloud_monitoring']['remote_http']['my_nodejs_app']['variables'] = {
  disabled: false,
  period: 60,
  timeout: 15,
  alarm: true,
  port: node['nodestack']['apps']['my_nodejs_app']['env']['PORT'],
  uri: '/',
  name: 'my_nodejs_app'
}

puts node['platformstack']['cloud_monitoring']['remote_http']
