include_recipe 'firewall'

firewall_rule 'ssh' do
  port 22
  action 'allow'
end

node['nodestack']['apps'].each_pair do |app_name, app_config| # each app loop
  firewall_rule 'http' do
    port app_config['http_port'].to_i
    action 'allow'
    only_if { app_config['http_port'] }
  end

  firewall_rule 'https' do
    port app_config['https_port'].to_i
    action 'allow'
    only_if { app_config['https_port'] && node['nodestack']['sslcert'] && node['nodestack']['sslkey'] }
  end

end
