# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::elasticsearch' do
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
          java
          elasticsearch
        )

        it 'includes the java recipe' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end
      end
    end
  end
end
