template "#{node['nodestack']['destination']}/server.js" do
  source "server.js.erb"
  owner node['nodestack']['username']
  mode 0644
  variables(
    :appUser => node['nodestack']['username']
  )
end

template "#{node['nodestack']['destination']}/package.json" do
  source "package.json.erb"
  owner node['nodestack']['username']
  mode 0644
  variables(
    :packages => node['nodestack']['packages'],
    :appName => node['nodestack']['appName']
  )
end

execute "install Node packages locally" do
  cwd node['nodestack']['destination']
  command "npm install"
  user node['nodestack']['username']
  environment ({'HOME' => "/home/#{node['nodestack']['username']}"})
end

%w{forever jslint}.each do |pkg|
  execute "install Node package #{pkg} globally" do
    command "npm install #{pkg} -g"
    environment ({'HOME' => "/home/#{node['nodestack']['username']}"})
  end
end

startAppCmd = "forever start server.js --http_port #{node['nodestack']['http_port']}"
if node['nodestack']['http_port'].to_i <= 1024
  startAppCmd = "sudo " + startAppCmd
end

execute "run app" do
  cwd node['nodestack']['destination']
  command startAppCmd
  user node['nodestack']['username']
  environment ({'HOME' => "/home/#{node['nodestack']['username']}"})
end
