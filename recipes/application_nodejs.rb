include_recipe 'chef-sugar'

if node.deep_fetch('mysql-multi', 'master')
  bindip = node['mysql-multi']['master']
else
  mysql = search('node', 'recipes:mysql-multi\:\:mysql_master'\
               " AND chef_environment:#{node.chef_environment}").first
  bindip = best_ip_for(mysql)
end

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

  execute 'install npm packages' do
    cwd app_config['app_dir'] + '/current'
    command 'npm install'
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
      entry: app_config['entry_point']
    )
    only_if { platform_family?('debian') }
  end

  template 'config.js' do
    path app_config['app_dir'] + '/current/config.js'
    source 'config.js.erb'
    owner app_config['app_user']
    group app_config['app_user']
    mode '0644'
    variables(
      http_port: app_config['http_port'],
      mysql_ip: bindip,
      mysql_user: app_config['app_db_user'],
      mysql_password: app_config['app_db_user_password']
    )
  end

  template "#{app_name}" do
    path "/etc/init.d/#{app_name}"
    source 'nodejs.initd.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(
      user: app_config['app_user'],
      group: app_config['app_user'],
      app_dir: app_config['app_dir'] + '/current',
      node_dir: node['nodejs']['dir'],
      entry: app_config['entry_point']
    )
    only_if { platform_family?('rhel') }
  end

  service app_name do
    case node['platform']
    when 'ubuntu'
      if node['platform_version'].to_f >= 9.10
        provider Chef::Provider::Service::Upstart
      end
    end
    action [:enable, :start]
  end

end # end each app loop
