# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::postgresql_base' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        recipes = %w(
          chef-sugar
          platformstack::iptables
          platformstack::monitors
          pg-multi
        )
        it 'includes recipes' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end

        # directory[/usr/lib/rackspace-monitoring-agent/plugins/]   nodestack/recipes/postgresql_base.rb:19
        it 'creates the monitoring plugins directory' do
          expect(chef_run).to create_directory('/usr/lib/rackspace-monitoring-agent/plugins/')
        end

        # remote_file[/usr/lib/rackspace-monitoring-agent/plugins/pg_check.py]   nodestack/recipes/postgresql_base.rb:27
        it 'creates the pg_check.py file' do
          expect(chef_run).to create_remote_file('/usr/lib/rackspace-monitoring-agent/plugins/pg_check.py')
        end

        # template[/etc/rackspace-monitoring-agent.conf.d/pg-monitor.yaml]   nodestack/recipes/postgresql_base.rb:35
        it 'creates the pg-monitor.yaml file' do
          expect(chef_run).to create_template('/etc/rackspace-monitoring-agent.conf.d/pg-monitor.yaml')
        end
      end
    end
  end
end
