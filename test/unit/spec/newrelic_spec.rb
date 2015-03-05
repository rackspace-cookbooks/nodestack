# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::newrelic' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        recipes = %w(
          platformstack::default
          newrelic::nodejs_agent
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
