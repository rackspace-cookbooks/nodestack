# Encoding: utf-8
# attributes/default.rb
if node['demo']
  default['nodestack']['apps']['my_nodejs_app']['app_dir'] = '/var/app'
  default['nodestack']['apps']['my_nodejs_app']['git_repo'] = 'git@github.com:marcoamorales/directory-rest-nodejs.git'
  default['nodestack']['apps']['my_nodejs_app']['git_repo_domain'] = 'github.com'
  default['nodestack']['apps']['my_nodejs_app']['entry_point'] = 'server.js'
  default['nodestack']['apps']['my_nodejs_app']['npm'] = true
  default['nodestack']['apps']['my_nodejs_app']['rev'] = 'HEAD'
  default['nodestack']['apps']['my_nodejs_app']['ssh_auth'] = true
  default['nodestack']['apps']['my_nodejs_app']['port'] = '80'
  default['nodestack']['apps']['my_nodejs_app']['port_local'] = '8080'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['port'] =  '8080'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mysql_password'] =  'randompass'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mongo_host'] =  '127.0.0.1'
  default['nodestack']['apps']['my_nodejs_app']['config_js']['mongo_port'] = 27_017
  default['nodestack']['cookbook'] = 'nodestack'
end
