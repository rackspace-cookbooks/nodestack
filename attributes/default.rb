# attributes/default.rb

default['nodestack']['appName'] = 'my_nodejs_app'
default['nodestack']['server_name'] = 'defaut_server.js'
default['nodestack']['destination'] = '/var/app'
default['nodestack']['app_user'] = 'nodejs'
default['nodestack']['git_repo'] = 'https://github.com/jrperritt/nodeTestApp.git'
default['nodestack']['rev'] = 'HEAD'
default['nodestack']['deploy_key'] = nil
default['nodestack']['domain'] = 'localhost'
default['nodestack']['http_port'] = '80'
default['nodestack']['https_port'] = '443'
default['nodestack']['sslcert'] = nil
default['nodestack']['sslkey'] = nil
default['nodestack']['sslcacert'] = nil
#A comma separated string of packages
default['nodestack']['packages'] = ''

set['authorization']['sudo']['users'] = ["#{node['nodestack']['app_user']}"]
node.set['authorization']['sudo']['passwordless'] = true
