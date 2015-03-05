# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::nginx' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'creates conf.d directory' do
          expect(chef_run).to create_directory('/etc/nginx/conf.d')
        end

        puts "rax-platform #{platform} #{version}"

        if platform == 'centos'
          it 'includes rhel recipes' do
            expect(chef_run).to include_recipe('yum-epel')
            expect(chef_run).to include_recipe('yum-ius')
          end
        end

        recipes = %w(
          chef-sugar
          apt
          platformstack::monitors
          platformstack::iptables
          nginx
        )

        it 'includes recipes' do
          recipes.each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end

        it 'creates these templates' do
          expect(chef_run).to create_template('/etc/nginx/conf.d/http_directives.conf')
          expect(chef_run).to create_template('/etc/nginx/sites-available/nodestack-demo-80.conf')
          expect(chef_run).to create_template('/etc/rackspace-monitoring-agent.conf.d/nodestack-demo.com-80-http-monitor.yaml') # cloud monitoring disabled
        end
      end
    end
  end
end
