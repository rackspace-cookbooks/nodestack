# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: setcap
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

case node['platform_family']
when 'rhel', 'fedora'
  package_name = 'libcap'
when 'debian'
  package_name = 'libcap2-bin'
end

package package_name do
  action 'install'
end

execute 'grant permissions to bind to low ports' do
  command 'setcap cap_net_bind_service=+ep /usr/local/bin/node'
  user 'root'
end
