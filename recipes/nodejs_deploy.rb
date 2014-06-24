include_recipe "git"

case node.platform
  when "debian", "ubuntu"
    package "git-core"
  when "rhel", "centos"
    package "git"
end

if node["nodejs_app"]["git_repo"] =~ /^git@/
  require 'uri'
  ### Temporarily convert ssh address to http protocol to find host easier ###
  uri = URI(node["nodejs_app"]["git_repo"].gsub(":","/").gsub(/git\@/, "http://"))
  host = uri.host
  ssh_known_hosts_entry host
end

key = node["nodejs_app"]["deploy_key"]
if key
  key = key.gsub("-----BEGIN RSA PRIVATE KEY-----", "").gsub("-----END RSA PRIVATE KEY-----", "").gsub(" ", "\n")
  git_deploy_key = "-----BEGIN RSA PRIVATE KEY-----\n" + key + "-----END RSA PRIVATE KEY-----"
end

application "create nodejs application" do
  path node["nodejs_app"]["destination"]
  owner node["nodejs_app"]["username"]
  repository node["nodejs_app"]["git_repo"]
  revision node["nodejs_app"]["rev"]
  if key
    deploy_key git_deploy_key
  end
end


execute "locally install npm packages from package.json" do
  cwd "#{node['nodejs_app']['destination']}/current"
  command "npm install"
  user node['nodejs_app']['username']
  environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
  only_if {::File.exists?("#{node['nodejs_app']['destination']}/current/package.json")}
end

execute "add forever to run app as daemon" do
  command "npm install forever -g"
  environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
end

startAppCmd = "forever start #{node['nodejs_app']['server_name']}"
if node['nodejs_app']['http_port'].to_i <= 1024
 startAppCmd = "sudo " + startAppCmd
end

execute "run app" do
  cwd "#{node['nodejs_app']['destination']}/current"
  command startAppCmd
  user node['nodejs_app']['username']
  environment ({'HOME' => "/home/#{node['nodejs_app']['username']}"})
  only_if {::File.exists?("#{node['nodejs_app']['destination']}/current/#{node['nodejs_app']['server_name']}")}
end
