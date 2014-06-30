# Encoding: utf-8
#
# Cookbook Name:: nodestack
# Recipe:: memcache
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

include_recipe 'platformstack::iptables'
include_recipe 'memcached'

memcache_port = node['memcached']['port']

add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{memcache_port} -j ACCEPT", 9999, 'Open TCP port for memcache')
add_iptables_rule('INPUT', "-m udp -p udp --dport #{memcache_port} -j ACCEPT", 9999, 'Open UDP port for memcache')
