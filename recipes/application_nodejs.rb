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

template "#{node['nodestack']['app_name']}.upstart.conf" do
  path "/etc/init/#{node['nodestack']['app_name']}_nodejs.conf"
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
end
