application "hello-world" do
  path "/var/app"
  owner "nodejs"
  group "nodejs"

  repository "git@github.com:jrperritt/nodeTestApp.git"

  nodejs do
    entry_point "server.js"
  end
end
