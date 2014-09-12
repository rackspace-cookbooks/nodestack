# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'nodestack::logrotate' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'includes the logrotate recipe' do
          expect(chef_run).to include_recipe('logrotate::default')
        end

        it 'configures logrotate for my_nodejs_app' do
          expect(chef_run).to enable_logrotate_app('my_nodejs_app')
        end
      end
    end
  end
end
