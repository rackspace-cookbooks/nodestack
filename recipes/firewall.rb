include_recipe 'firewall'

firewall_rule "ssh" do
  port 22
  action :allow
end

firewall_rule "http" do
  port node["nodestack"]["http_port"].to_i
  action :allow
end

if node["nodestack"]["sslcert"] and node["nodestack"]["sslkey"]
  firewall_rule "https" do
    port node["nodestack"]["https_port"].to_i
    action :allow
  end
end
