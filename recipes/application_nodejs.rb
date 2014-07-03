# Encoding: utf-8
include_recipe 'chef-sugar'

# mysql-multi defaults to default['mysql-mutli']['master'] = ''
if node.deep_fetch('mysql-multi', 'master') && !node['mysql-multi']['master'].empty?
  bindip = node['mysql-multi']['master']
elsif node.deep_fetch('mysql-multi', 'bind_ip') && !node['mysql-multi']['bind_ip'].empty?
  # if a bind IP is set for the cluster, use it for all app nodes
  bindip = node['mysql-multi']['bind_ip']
else
  if node['mysql-multi']['master'].empty?
    mysql = search('node', 'recipes:nodestack\:\:mysql_base'\
               " AND chef_environment:#{node.chef_environment}").first
  else
    mysql = search('node', 'recipes:nodestack\:\:mysql_master'\
               " AND chef_environment:#{node.chef_environment}").first
  end
  bindip = best_ip_for(mysql)
end

%w( 'forever-agent'
    'coffee-script'
    'grunt-contrib-watch'
    'pm2'
    'nodemon' ).each do |npm_pkg|
  execute "install #{npm_pkg}" do
    command "npm install -g #{npm_pkg}"
    not_if { installed?(npm_pkg) }
  end
end

execute 'pm2 startup centos' do
  not_if { ::File.exist?('/etc/init.d/pm2-init.sh') }
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

  nodestack_app app_name do
    path app_config['app_dir'] + '/current'
    js app_config['entry_point']
    user app_config['app_user']
    group app_config['app_user']
    port app_config['http_port']
    action 'create'
  end

  execute 'install npm packages' do
    cwd app_config['app_dir'] + '/current'
    command 'npm install'
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
      mysql_user: app_name,
      mysql_password: app_config['mysql_app_user_password'],
      mysql_db_name: app_name
    )
  end
end # end each app loop
