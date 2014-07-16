# Encoding: utf-8
# attributes/default.rb
if node['demo']
  default['nodestack']['apps']['my_nodejs_app']['app_dir'] = '/var/app'
  default['nodestack']['apps']['my_nodejs_app']['git_repo'] = 'git@github.com:marcoamorales/directory-rest-nodejs.git'
  default['nodestack']['apps']['my_nodejs_app']['git_repo_domain'] = 'github.com'
  default['nodestack']['apps']['my_nodejs_app']['entry_point'] = 'server.js'
  default['nodestack']['apps']['my_nodejs_app']['rev'] = 'HEAD'
  default['nodestack']['apps']['my_nodejs_app']['ssh_auth'] = true
  default['nodestack']['apps']['my_nodejs_app']['http_port'] = '8080'
  default['nodestack']['apps']['my_nodejs_app']['https_port'] = '443'
  default['nodestack']['apps']['my_nodejs_app']['mysql_app_user_password'] = 'randompass'
  default['nodestack']['apps']['my_nodejs_app']['mongo_host'] = '127.0.0.1'
  default['mongodb']['port']   = 27_017
  default['nodestack']['cookbook'] = 'nodestack'
end
