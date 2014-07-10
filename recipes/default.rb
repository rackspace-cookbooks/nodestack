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

node['nodestack']['apps'].each_pair do |_app_name, app_config| # each app loop
  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['http_port']} -j ACCEPT", 100, 'Allow nodejs http traffic')
  add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{app_config['https_port']} -j ACCEPT", 100, 'Allow nodejs https traffic')
end
