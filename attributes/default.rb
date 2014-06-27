# attributes/default.rb

default['nodestack']['app_name'] = 'my_nodejs_app'
default['nodestack']['server_name'] = 'defaut_server.js'
default['nodestack']['app_dir'] = '/var/app'
default['nodestack']['app_user'] = 'nodejs'
default['nodestack']['git_repo'] = 'https://github.com/jrperritt/nodeTestApp.git'
default['nodestack']['entry_point'] = 'server.js'
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

