include_recipe "git"

case node.platform
  when "debian", "ubuntu"
    package "git-core"
  when "rhel", "centos"
    package "git"
end

if node["nodestack"]["git_repo"] =~ /^git@/
  require 'uri'
  ### Temporarily convert ssh address to http protocol to find host easier ###
  uri = URI(node["nodestack"]["git_repo"].gsub(":","/").gsub(/git\@/, "http://"))
  host = uri.host
  ssh_known_hosts_entry host
end

key = node["nodestack"]["deploy_key"]
if key
  key = key.gsub("-----BEGIN RSA PRIVATE KEY-----", "").gsub("-----END RSA PRIVATE KEY-----", "").gsub(" ", "\n")
  git_deploy_key = "-----BEGIN RSA PRIVATE KEY-----\n" + key + "-----END RSA PRIVATE KEY-----"
end

application "create nodejs application" do
  path node["nodestack"]["destination"]
  owner node["nodestack"]["username"]
  repository node["nodestack"]["git_repo"]
  revision node["nodestack"]["rev"]
  if key
    deploy_key git_deploy_key
  end
end


execute "locally install npm packages from package.json" do
  cwd "#{node['nodestack']['destination']}/current"
  command "npm install"
  user node['nodestack']['username']
  environment ({'HOME' => "/home/#{node['nodestack_app']['username']}"})
  only_if {::File.exists?("#{node['nodestack']['destination']}/current/package.json")}
end

execute "add forever to run app as daemon" do
  command "npm install forever -g"
  environment ({'HOME' => "/home/#{node['nodestack']['username']}"})
end

startAppCmd = "forever start #{node['nodestack']['server_name']}"
if node['nodestack']['http_port'].to_i <= 1024
 startAppCmd = "sudo " + startAppCmd
end

execute "run app" do
  cwd "#{node['nodestack']['destination']}/current"
  command startAppCmd
  user node['nodestack']['username']
  environment ({'HOME' => "/home/#{node['nodestack']['username']}"})
  only_if {::File.exists?("#{node['nodestack']['destination']}/current/#{node['nodestack']['server_name']}")}
end
