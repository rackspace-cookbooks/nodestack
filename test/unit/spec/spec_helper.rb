# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'
require 'json'

RSpec.configure do |config|
  config.extend(ChefSpec::Cacher)
end

Dir['./test/unit/spec/support/**/*.rb'].sort.each { |f| require f }

::LOG_LEVEL = :fatal
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

# This can probably be moved to a more
# elegant call to an external file at
# some point

def server_resources(server)
  # for chef-zero
  server.create_environment('demo', JSON.parse(File.read('test/integration/environments/demo.json')))
end

# rubocop:disable AbcSize
def node_resources(node)
  fail 'Spec Helper was passed a nil/false node object' unless node
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
  node.set['platformstack']['cloud_monitoring']['enabled'] = true
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
  node.set['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink'] = 'test_before_symlink.rb'
  node.set['nodestack']['apps']['my_nodejs_app']['deployment']['before_symlink_template'] = 'before_symlink_test.rb.erb'
  node.set['nodestack']['apps']['my_nodejs_app']['deployment']['strategy'] = 'forever'
  node.set['nodestack']['cookbook'] = 'nodestack'

  # Gluster info
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster01']['ip'] = '33.33.33.10'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster01']['block_device'] = '/dev/sdb'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster01']['mount_point'] = '/mnt/brick0'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster01']['brick_dir'] = '/mnt/brick0/brick'

  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster02']['ip'] = '33.33.33.11'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster02']['block_device'] = '/dev/sdb'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster02']['mount_point'] = '/mnt/brick0'
  node.set['rackspace_gluster']['config']['server']['glusters']['Gluster Cluster 1']['nodes']['gluster02']['brick_dir'] = '/mnt/brick0/brick'

  # MySQL
  node.set['holland']['enabled'] = true

  # NewRelic
  node.set['newrelic']['license'] = 'foo'

  # PostGreSQL
  node.set['postgresql']['password']['postgres'] = 'randompasswordforpostgresql'

  # no need to converge elkstack agent for this
  node.set['platformstack']['elkstack_logging']['enabled'] = false
end
# rubocop:enable AbcSize

# rubocop:disable AbcSize
def stub_resources
  # Even though this is set in the check itself for readibility
  # I get all failures if I remove this stub_command from here
  stub_command('test -L /usr/bin/nodejs').and_return(false)

  # Make sure that files not specifically mocked aren't included below
  allow(File).to receive(:exist?).and_call_original

  # Mock to allow npm to install the application
  allow(File).to receive(:exist?).with('/var/app/current/package.json').and_return(true)

  # MySQL Add Drive stubs/mocks
  stub_command('mkfs -t ext3 /dev/xvde1').and_return(true)
  allow(File).to receive(:blockdev?).with('/dev/xvde1').and_return(true)

  shellout = double
  allow(Mixlib::ShellOut).to receive(:new).with('blkid -s TYPE -o value /dev/xvde1').and_return(shellout)
  allow(shellout).to receive(:run_command).and_return(shellout)
  allow(shellout).to receive(:error!).and_return(true) # true so it runs the format command
  allow(shellout).to receive(:error?).and_return(true)

  stub_command("psql -c \"SELECT rolname FROM pg_roles WHERE rolname='repl'\" | grep repl").and_return('foo')
end
# rubocop:enable AbcSize

at_exit { ChefSpec::Coverage.report! }

# Memoized runner
module RackspaceChefSpec
  # Memoized runner
  module SpecHelper
    # rubocop:disable Style/ClassVars
    @@runner = {}

    def memoized_runner(options = {})
      platform = options['platform']
      version = options['version']

      # inflate the platform key so we can check for a version
      @@runner[platform] = {} if @@runner[platform].nil?

      unless @@runner[platform][version]
        puts "new serverrunner #{platform}#{version}"
        @@runner[platform][version] = ChefSpec::ServerRunner.new(options) do |node, server|
          yield node, server if block_given?
        end
      end
      @@runner[platform][version]
    end
  end
end

# give a way to clean out / kill off the node data from a previous run
module ChefSpec
  # clean the node
  class SoloRunner
    def clean_node
      @node = nil
      # rubocop:disable Style/RedundantSelf
      self.node
    end
  end
end

RSpec.configure do |config|
  config.include RackspaceChefSpec::SpecHelper

  # change to :info or :debug for walls of text
  config.log_level = :warn
end
