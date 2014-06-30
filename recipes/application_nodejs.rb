include_recipe 'chef-sugar'

application "nodejs application" do
  path node['nodestack']['app_dir']
  owner node['nodestack']['app_user']
  group node['nodestack']['app_user']

  repository node['nodestack']['git_repo']

end

execute "install npm packages" do
  cwd node['nodestack']['app_dir'] + '/current'
  command 'npm install'
end

template "#{node['nodestack']['app_name']}.conf" do
  path "/etc/init/#{node['nodestack']['app_name']}.conf"
  source 'nodejs.upstart.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :user => node['nodestack']['app_user'],
    :group => node['nodestack']['app_user'],
    :app_dir => node['nodestack']['app_dir'] + '/current',
    :node_dir => node['nodejs']['dir'],
    :entry => node['nodestack']['entry_point'],
  )
  only_if { platform_family?("debian") }
end

if node.deep_fetch('mysql-multi', 'master')
  bindip = node['mysql-multi']['master']
else
  mysql = search('node', 'recipes:mysql-multi\:\:mysql_master'\
               " AND chef_environment:#{node.chef_environment}").first
  bindip = best_ip_for(mysql)
end

template "config.js" do
  path node['nodestack']['app_dir'] + '/current/config.js'
  source 'config.js.erb'
  owner node['nodestack']['app_user']
  group node['nodestack']['app_user']
  mode '0644'
  variables(
    :listening_port => node['nodestack']['listening_port'],
    :mysql_ip => bindip,
    :mysql_user => node['nodestack']['app_db_user'],
    :mysql_password => node['nodestack']['app_db_user_password']
  )
end

template "#{node['nodestack']['app_name']}" do
  path "/etc/init.d/#{node['nodestack']['app_name']}"
  source 'nodejs.initd.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :user => node['nodestack']['app_user'],
    :group => node['nodestack']['app_user'],
    :app_dir => node['nodestack']['app_dir'] + '/current',
    :node_dir => node['nodejs']['dir'],
    :entry => node['nodestack']['entry_point'],
  )
  only_if { platform_family?("rhel") }
end

service "#{node['nodestack']['app_name']}" do
  case node['platform']
  when 'ubuntu'
    if node['platform_version'].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [ :enable, :start]
end
