# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'nodestack::memcache' do
  before { stub_resources }

  platform = 'ubuntu'
  version = '12.04'

  cached('runner') do
    ChefSpec::ServerRunner.new(platform: platform, version: 'version', log_level: LOG_LEVEL) do |node, server|
      # memoized_runner(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      node_resources(node)
    end
  end

  let(:chef_run) do
    ChefSpec::Runner.new(platform: platform, version: version) do |node|
      node_resources(node)
    end.converge(described_recipe)
  end

  recipes = %w(
    platformstack::iptables
    memcached
  )

  it 'includes recipes' do
    recipes.each do |recipe|
      expect(chef_run).to include_recipe(recipe)
    end
  end
end
