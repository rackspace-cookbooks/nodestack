application "create nodejs application" do
  path node["nodestack"]["destination"]
  owner node["nodestack"]["app_user"]
  group node["nodestack"]["app_user"]
  repository node["nodestack"]["git_repo"]
  revision node["nodestack"]["rev"]

  #nodejs do
  #npm true
    #entry_point 'server.js'
  #end
end
