# Encoding: utf-8

require_relative 'spec_helper'

# If you run this spec solo it will fail due
# to the inclusion of nodestack::mysql_base
describe 'nodestack::mysql_slave' do
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
          nodestack::mysql_base
          mysql-multi::mysql_slave
        )
        it 'includes recipes' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end
      end
    end
  end
end
