# Encoding: utf-8
# Copyright 2014, Rackspace

include_recipe 'chef-sugar'

mysql_node = search('node', 'recipes:nodestack\:\:mysql_master' << " AND chef_environment:#{node.chef_environment}").first

node['nodestack']['apps'].each_pair do |app_name, app_config| # each app loop

  user app_config['app_user'] do
    supports manage_home: true
    shell '/bin/bash'
    home "/home/#{app_config['app_user']}"
  end

  application 'nodejs application' do
    path app_config['app_dir']
    owner app_config['app_user']
    group app_config['app_user']
    repository app_config['git_repo']
  end

  template 'config.js' do
    path app_config['app_dir'] + '/current/config.js'
    source 'config.js.erb'
    owner app_config['app_user']
    group app_config['app_user']
    mode '0644'
    variables(
      http_port: app_config['http_port'],
      mysql: mysql_node.respond_to?('deep_fetch') == true ? mysql_node : nil,
      mysql_user: app_name,
      mysql_password: app_config['mysql_app_user_password'],
      mysql_db_name: app_name
    )
  end

  execute 'locally install npm packages from package.json' do
    cwd "#{app_config['app_dir']}/current"
    command "npm install"
    user app_config['app_user']
    environment ({'HOME' => "/home/#{app_config['app_user']}"})
    only_if {::File.exists?("#{app_config['app_dir']}/current/package.json")}
  end

  execute "add forever to run app as daemon" do
    command "npm install forever -g"
    environment ({'HOME' => "/home/#{app_config['app_user']}"})
  end

template app_name do
    path "/etc/init.d/#{app_name}"
    source 'nodejs.initd.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      user: app_config['app_user'],
      group: app_config['app_user'],
      app_dir: app_config['app_dir'] + '/current',
      entry: app_config['entry_point']
    )
    only_if { platform_family?('rhel') }
  end

  template "#{app_name}.conf" do
    path "/etc/init/#{app_name}.conf"
    source 'nodejs.upstart.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      user: app_config['app_user'],
      group: app_config['app_user'],
      app_dir: app_config['app_dir'] + '/current',
      node_dir: node['nodejs']['dir'],
      entry: app_config['entry_point'],
      app_name: app_name
    )
    only_if { platform_family?('debian') }
  end

  service app_name do
    case node['platform']
    when 'ubuntu'
        provider Chef::Provider::Service::Upstart
    end
    action [:enable, :start]
  end
end # end each app loop
