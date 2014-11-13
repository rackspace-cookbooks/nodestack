# Encoding: utf-8
# attributes/default.rb

# stackname = 'nodestack'
default['stack_commons']['stackname'] = 'nodestack'

case node['platform_family']
when 'rhel', 'fedora'
  default['nodejs']['install_method'] = 'binary'
  default['nodestack']['binary_path'] = '/usr/local/bin/node'
when 'debian'
  default['nodejs']['install_method'] = 'package'
  default['nodestack']['binary_path'] = '/usr/bin/nodejs'
end

default['nodestack']['code_deployment'] = true
