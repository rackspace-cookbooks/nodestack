# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::cloud_monitoring' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe, 'platformstack::monitors')
        end

        app_name = 'my_nodejs_app'

        it 'installs the cloud monitoring file' do
          expect(chef_run).to create_template("/etc/rackspace-monitoring-agent.conf.d/#{app_name}-http-monitor.yaml")
        end

      end
    end
  end
end
