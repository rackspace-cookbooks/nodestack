# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::forever' do
  before { stub_resources }

  platform = 'ubuntu'
  version = '12.04'

  let(:runner) do
    memoized_runner(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      node_resources(node)
      server_resources(server)
    end
  end

  let(:chef_run) do
    node_resources(runner.clean_node)
    runner.converge('nodestack::forever')
  end

  it 'creates template for init' do
    expect(chef_run).to create_template('/etc/init/my_nodejs_app.conf')
  end

  # service[my_nodejs_app]             nodestack/recipes/application_nodejs.rb:197
  it 'enables and starts the my_nodejs_app service' do
    expect(chef_run).to enable_service('my_nodejs_app').with(
      service_name: 'my_nodejs_app',
      supports: { restart: false, reload: false, status: false }
    )
  end
end
