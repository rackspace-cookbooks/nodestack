# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack application_nodejs recipes' do
  before { stub_resources }

  platform = 'ubuntu'
  version = '12.04'

  # no need for cached here since memoized_runner will do it anyway
  let(:runner) do
    memoized_runner(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      node_resources(node)
      server_resources(server)
    end
  end

  let(:chef_run) do
    node_resources(runner.clean_node)
    runner.converge('nodestack::application_nodejs')
  end

  app_name = 'my_nodejs_app'

  # application[nodejs application]    nodestack/recipes/application_nodejs.rb:137
  it 'deploys application' do
    expect(chef_run).to deploy_application('nodejs application')
  end

  # directory[/home/my_nodejs_app/.npm]   nodestack/recipes/application_nodejs.rb:60
  # directory[/home/my_nodejs_app/.ssh]   nodestack/recipes/application_nodejs.rb:67
  # directory[/var/app/logs]           nodestack/recipes/application_nodejs.rb:121
  # directory[/var/app/pids]           nodestack/recipes/application_nodejs.rb:121
  directories = [
    "/home/#{app_name}/.npm",
    "/home/#{app_name}/.ssh",
    '/var/app/logs',
    '/var/app/pids'
  ]
  it 'creates a directory with the default action' do
    directories.each do |directory|
      expect(chef_run).to create_directory(directory)
    end
  end

  # magic_shell_environment[PORT]      nodestack/recipes/application_nodejs.rb:131
  # magic_shell_environment[MONGO_PORT]   nodestack/recipes/application_nodejs.rb:131
  magic_shell_environments = %w(
    PORT
    MONGO_PORT
  )
  it 'adds a new magic_shell_environment' do
    magic_shell_environments.each do |msenv|
      expect(chef_run).to add_magic_shell_environment(msenv)
    end
  end

  # nodejs_npm[npm-install-retry]      nodestack/recipes/application_nodejs.rb:159
  # nodejs_npm[forever]                nodestack/recipes/application_nodejs.rb:176
  # nodejs_npm[my_nodejs_app]          nodestack/recipes/application_nodejs.rb:165
  npm_packages = %w(
    forever
    my_nodejs_app
  )
  it 'installs npm package' do
    npm_packages.each do |npm_package|
      expect(chef_run).to install_nodejs_npm(npm_package)
    end
  end

  # sudo[my_nodejs_app]                nodestack/recipes/application_nodejs.rb:54
  # This test isn't really testing to see if the my_nodejs_app user
  # is being added, its generically checking to see if sudo was installed
  it "adds the #{app_name} user to /etc/sudoers" do
    expect(chef_run).to install_sudo(app_name)
  end

  # template[config.js]                nodestack/recipes/application_nodejs.rb:146
  # template[my_nodejs_app]            nodestack/recipes/application_nodejs.rb:102
  # template[server.js for forever]    nodestack/recipes/application_nodejs.rb:183
  # template[ssh config with strict host check disabled]   nodestack/recipes/application_nodejs.rb:74
  templates = ["/home/#{app_name}/.ssh/config",
               '/var/app/server.js',
               '/var/app/current/config.js'
              ]
  it 'creates a template with the default action' do
    templates.each do |template|
      expect(chef_run).to create_template(template)
    end
  end

  # user[my_nodejs_app]                nodestack/recipes/application_nodejs.rb:48
  it "creates the #{app_name} user" do
    expect(chef_run).to create_user(app_name).with(
      home: "/home/#{app_name}",
      shell: '/bin/bash'
    )
  end
end
