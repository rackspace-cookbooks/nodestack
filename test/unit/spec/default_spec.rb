# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::application_nodejs' do
  before { stub_resources }
  describe 'ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(UBUNTU_OPTS) do |node|
        node_resources(node)

        node.automatic['lsb']['codename'] = 'lucid'
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    # application[nodejs application]    nodestack/recipes/application_nodejs.rb:137
    it 'deploys application' do
      expect(chef_run).to deploy_application('nodejs application')
    end

    # directory[/home/my_nodejs_app/.npm]   nodestack/recipes/application_nodejs.rb:60
    # directory[/home/my_nodejs_app/.ssh]   nodestack/recipes/application_nodejs.rb:67
    # directory[/var/app/logs]           nodestack/recipes/application_nodejs.rb:121
    # directory[/var/app/pids]           nodestack/recipes/application_nodejs.rb:121
    directories = %w(
      /home/my_nodejs_app/.npm
      /home/my_nodejs_app/.ssh
      /var/app/logs
      /var/app/pids
    )

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
      npm-install-retry
      forever
      my_nodejs_app
    )
    it 'installs npm package' do
      npm_packages.each do |npm_package|
        expect(chef_run).to install_nodejs_npm(npm_package)
      end
    end

    # package[libcap2-bin]               nodestack/recipes/setcap.rb:28
    it 'installs package libcap2-bin' do
      expect(chef_run).to install_package('libcap2-bin')
    end

    # service[my_nodejs_app]             nodestack/recipes/application_nodejs.rb:197
    app_name = 'my_nodejs_app'
    it 'enables and starts the my_nodejs_app service' do
      expect(chef_run).to enable_service('my_nodejs_app').with(
        service_name: app_name,
        init_command: "/etc/init/#{app_name}",
        restart_command: "/sbin/initctl stop #{app_name} && /sbin/initctl start #{app_name}",
        supports: { restart: false, reload: false, status: false }
      )
    end
    
    # sudo[my_nodejs_app]                nodestack/recipes/application_nodejs.rb:54
    # This test isn't really testing to see if the my_nodejs_app user
    # is being added, its generically checking to see if sudo was installed  
    it 'adds the my_nodejs_app user to /etc/sudoers' do
      expect(chef_run).to install_sudo('my_nodejs_app')
    end

    # template[config.js]                nodestack/recipes/application_nodejs.rb:146
    # template[my_nodejs_app]            nodestack/recipes/application_nodejs.rb:102
    # template[server.js for forever]    nodestack/recipes/application_nodejs.rb:183
    # template[ssh config with strict host check disabled]   nodestack/recipes/application_nodejs.rb:74
    templates = %w(
      /home/my_nodejs_app/.ssh/config
      /etc/init/my_nodejs_app.conf
      /var/app/server.js
      /var/app/current/config.js
    )
    it 'creates a template with the default action' do
      templates.each do |template|
        expect(chef_run).to create_template(template)
      end
    end

    # user[my_nodejs_app]                nodestack/recipes/application_nodejs.rb:48
    it 'creates a user with the default action' do
      expect(chef_run).to create_user(app_name).with(
        home: "/home/#{app_name}",
        shell: '/bin/bash'
      )
    end

    # TODO
    # execute[grant permissions to bind to low ports if path is binary]   nodestack/recipes/setcap.rb:32
    #stub_command('test -L /usr/bin/nodejs').and_return(false)
    it 'binds low ports if path is binary' do
      expect(chef_run).to run_execute("setcap cap_net_bind_service=+ep /usr/bin/nodejs")
    end
    it 'binds low ports if path is symlink' do
      stub_command('test -L /usr/bin/nodejs').and_return(true)
      expect(chef_run).to run_execute("setcap cap_net_bind_service=+ep $(readlink /usr/bin/nodejs)")
    end
    # execute[grant permissions to bind to low ports if path is symlink]   nodestack/recipes/setcap.rb:38

  end
end
