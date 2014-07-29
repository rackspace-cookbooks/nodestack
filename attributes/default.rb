# Encoding: utf-8
# attributes/default.rb
case node['platform_family']
when 'rhel', 'fedora'
  default['nodejs']['install_method'] = 'binary'
  default['nodestack']['binary_path'] = '/usr/local/bin/node'
when 'debian'
  default['nodejs']['install_method'] = 'package'
  default['nodestack']['binary_path'] = '/usr/bin/nodejs'
end
if node['demo']
  default['nodestack']['apps_to_deploy'] = ['my_nodejs_app']
  default['nodestack']['apps']['my_nodejs_app']['app_dir'] = '/var/app'
  default['nodestack']['apps']['my_nodejs_app']['git_repo'] = 'git@github.com:marcoamorales/node-hello-world.git'
  default['nodestack']['apps']['my_nodejs_app']['git_rev'] = 'HEAD'
  default['nodestack']['apps']['my_nodejs_app']['git_repo_domain'] = 'github.com'
  default['nodestack']['apps']['my_nodejs_app']['entry_point'] = 'app.js'
  default['nodestack']['apps']['my_nodejs_app']['npm'] = true
  default['nodestack']['apps']['my_nodejs_app']['ssh_auth'] = true
  default['nodestack']['apps']['my_nodejs_app']['config_file'] = true
  default['nodestack']['apps']['my_nodejs_app']['config_js']['port'] =  '80'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mysql_password'] =  'randompass'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mongo_host'] =  '127.0.0.1'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mongo_port'] = 27_017
  default['nodestack']['apps']['my_nodejs_app']['env']['PORT'] = '80'
  default['nodestack']['apps']['my_nodejs_app']['env']['MONGO_PORT'] = '27017'
  default['nodestack']['cookbook'] = 'nodestack'
end
