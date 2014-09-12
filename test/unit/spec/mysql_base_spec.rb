# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::mysql_base' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        property = load_platform_properties(platform: platform, platform_version: version)

        recipes = %w(
          chef-sugar
          database::mysql
          platformstack::monitors
          mysql::server
          mysql-multi
        )

        recipes.push('apt') if property['platform_family'] == 'debian'

        it 'includes recipes' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end

        # mysql_database_user[holland]       nodestack/recipes/mysql_base.rb:40
        # mysql_database_user[raxmon-agent]   nodestack/recipes/mysql_base.rb:53
        # mysql_database_user[my_nodejs_app]   nodestack/recipes/mysql_base.rb:96
        mysql_users = %w(
          holland
          raxmon-agent
          my_nodejs_app
        )
        it 'adds mysql users' do
          mysql_users.each do |user|
            expect(chef_run).to create_mysql_database_user(user)
          end
        end

        # template[mysql-monitor]            nodestack/recipes/mysql_base.rb:59
        it 'adds the mysql monitor' do
          expect(chef_run).to create_template('/etc/rackspace-monitoring-agent.conf.d/agent-mysql-monitor.yaml')
        end
      end
    end
  end
end
