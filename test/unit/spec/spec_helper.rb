# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'
require 'json'

::LOG_LEVEL = :fatal
::UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '12.04',
  log_level: ::LOG_LEVEL
}
::CENTOS_OPTS = {
  platform: 'centos',
  version: '6.5',
  log_level: ::LOG_LEVEL
}
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

# This can probably be moved to a more
# elegant call to an external file at
# some point
def node_resources(node)
  # Setup databag
  env = Chef::Environment.new
  env.name 'demo'
  allow(node).to receive(:chef_environment).and_return(env.name)
  allow(Chef::Environment).to receive(:load).and_return(env)
  data_bag = JSON.parse(File.read('test/integration/default/data_bags/my_nodejs_app_databag/config.json'))
  allow(Chef::EncryptedDataBagItem).to receive(:load).with('my_nodejs_app_databag', 'config').and_return(data_bag)

  # Setup system attributes
  node.set['memory']['total'] = 2048
  node.set['cpu']['total'] = 2

  # Dummy mount point so cloud monitoring doesn't fail
  node.set['platformstack']['cloud_monitoring']['filesystem']['target']['mnt'] = 'foo'

  # NodeJS app info
  node.set['nodestack']['apps_to_deploy'] = ['my_nodejs_app']
  node.set['nodestack']['binary_path'] = '/usr/bin/nodejs'
  node.set['nodestack']['apps']['my_nodejs_app']['app_dir'] = '/var/app'
  node.set['nodestack']['apps']['my_nodejs_app']['git_repo'] = 'git@github.com:marcoamorales/node-hello-world.git'
  node.set['nodestack']['apps']['my_nodejs_app']['git_rev'] = 'HEAD'
  node.set['nodestack']['apps']['my_nodejs_app']['git_repo_domain'] = 'github.com'
  node.set['nodestack']['apps']['my_nodejs_app']['entry_point'] = 'app.js'
  node.set['nodestack']['apps']['my_nodejs_app']['npm'] = true
  node.set['nodestack']['apps']['my_nodejs_app']['config_file'] = true
  node.set['nodestack']['apps']['my_nodejs_app']['env']['PORT'] = '80'
  node.set['nodestack']['apps']['my_nodejs_app']['env']['MONGO_PORT'] = '27017'
  node.set['nodestack']['apps']['my_nodejs_app']['monitoring']['body'] = 'Hello World!'
  node.set['nodestack']['cookbook'] = 'nodestack'
end

def stub_resources
  stub_command('test -L /usr/bin/nodejs').and_return('foo')
end

at_exit { ChefSpec::Coverage.report! }
