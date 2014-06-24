# attributes/default.rb

default["nodejs_app"]["appName"] = "my_nodejs_app"
default["nodejs_app"]["server_name"] = "defaut_server.js"
default["nodejs_app"]["destination"] = "/var/app"
default["nodejs_app"]["git_repo"] = nil
default["nodejs_app"]["rev"] = "HEAD"
default["nodejs_app"]["deploy_key"] = nil
default["nodejs_app"]["domain"] = "localhost"
default["nodejs_app"]["http_port"] = "80"
default["nodejs_app"]["https_port"] = "443"
default["nodejs_app"]["sslcert"] = nil
default["nodejs_app"]["sslkey"] = nil
default["nodejs_app"]["sslcacert"] = nil
#A comma separated string of packages
default["nodejs_app"]["packages"] = ""

set['authorization']['sudo']['users'] = ["#{node['nodejs_app']['username']}"]
node.set['authorization']['sudo']['passwordless'] = true
