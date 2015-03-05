# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::setcap' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        property = load_platform_properties(platform: platform, platform_version: version)

        # package[libcap2-bin]               nodestack/recipes/setcap.rb:28
        it "installs package #{property['libcap_package']}" do
          expect(chef_run).to install_package("#{property[:libcap_package]}")
        end

        # execute[grant permissions to bind to low ports if path is binary]   nodestack/recipes/setcap.rb:32
        it 'binds low ports if path is binary' do
          stub_command('test -L /usr/bin/nodejs').and_return(false)
          expect(chef_run).to run_execute('setcap cap_net_bind_service=+ep /usr/bin/nodejs')
        end

        # execute[grant permissions to bind to low ports if path is symlink]   nodestack/recipes/setcap.rb:38
        it 'binds low ports if path is symlink' do
          stub_command('test -L /usr/bin/nodejs').and_return(true)
          expect(chef_run).to run_execute('setcap cap_net_bind_service=+ep $(readlink /usr/bin/nodejs)')
        end
      end
    end
  end
end
