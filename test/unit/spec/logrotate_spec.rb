# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'nodestack::logrotate' do
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
    runner.converge('nodestack::logrotate')
  end

  it 'includes the logrotate recipe' do
    expect(chef_run).to include_recipe('logrotate::default')
  end

  it 'configures logrotate for my_nodejs_app' do
    expect(chef_run).to enable_logrotate_app('my_nodejs_app')
  end
end
