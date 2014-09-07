# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::application_nodejs' do
  before { stub_resources }
  describe 'ubuntu 12.04' do
    let(:chef_run) do
      ChefSpec::Runner.new(UBUNTU_OPTS) do |node|
        node_resources(node)

        node.automatic['lsb']['codename'] = 'lucid'
        node.automatic['platform_family'] = 'debian'
      end.converge(described_recipe)
    end

    it 'installs package libcap2-bin' do
      expect(chef_run).to install_package('libcap2-bin')
    end

  end
end
