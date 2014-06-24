include_recipe 'firewall'

firewall_rule "ssh" do
  port 22
  action :allow
end

firewall_rule "http" do
  port node["nodejs_app"]["http_port"].to_i
  action :allow
end

if node["nodejs_app"]["sslcert"] and node["nodejs_app"]["sslkey"]
  firewall_rule "https" do
    port node["nodejs_app"]["https_port"].to_i
    action :allow
  end
end