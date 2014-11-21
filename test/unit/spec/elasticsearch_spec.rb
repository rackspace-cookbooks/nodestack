# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::elasticsearch' do
  before { stub_resources }

  platform = 'ubuntu'
  version = '12.04'

  let(:runner) do
    memoized_runner(platform: platform, version: version, log_level: LOG_LEVEL) do |node, server|
      node_resources(node)
      server_resources(server)
    end
  end


  #let(:chef_run) do
  #  node_resources(runner.clean_node)
  #  recipes.each do |recipe|
  #    runner.converge(recipe)
  #  end
  #end

  let(:chef_run) do
    node_resources(runner.clean_node)
    runner.converge('nodestack::elasticsearch')
  end


  %w(
          java::default
          elasticsearch::default
  ).each do |recipe|

    it "includes the #{recipe} recipe" do
      expect(chef_run).to include_recipe(recipe)
    end
  end
  #it 'includes the java recipe' do
  #  expect(chef_run).to include_recipe('java::default')
  #end
  #it 'includes the java recipe' do
  #  expect(chef_run).to include_recipe('elasticsearch::default')
  #end
end
