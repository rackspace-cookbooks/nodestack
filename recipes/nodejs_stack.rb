template "#{node['nodejs_app']['destination']}/server.js" do
  source "server.js.erb"
  owner node['nodejs_app']['username']
  mode 0644
  variables(
    :appUser => node['nodejs_app']['username']
  )
end

template "#{node['nodejs_app']['destination']}/package.json" do
  source "package.json.erb"
  owner node['nodejs_app']['username']
  mode 0644
  variables(
    :packages => node['nodejs_app']['packages'],
    :appName => node['nodejs_app']['appName']
  )
end

execute "install Node packages locally" do
  cwd node['nodejs_app']['destination']
  command "npm install"
  user node['nodejs_app']['username']
  environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
end

%w{forever jslint}.each do |pkg|
  execute "install Node package #{pkg} globally" do
    command "npm install #{pkg} -g"
    environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
  end
end

startAppCmd = "forever start server.js --http_port #{node['nodejs_app']['http_port']}"
if node['nodejs_app']['http_port'].to_i <= 1024
  startAppCmd = "sudo " + startAppCmd
end

execute "run app" do
  cwd node['nodejs_app']['destination']
  command startAppCmd
  user node['nodejs_app']['username']
  environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
end
