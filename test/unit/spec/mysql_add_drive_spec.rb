# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::mysql_add_drive' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'performs a mkfs' do
          expect(chef_run).to run_execute('mkfs -t ext4 /dev/xvde1')
        end

        # user[mysql]                        nodestack/recipes/mysql_add_drive.rb:45
        it 'adds the mysql user' do
          expect(chef_run).to create_user('mysql').with(
            comment: 'MySQL Server',
            home: '/var/lib/mysql',
            shell: '/sbin/nologin'
          )
        end

        # directory[/var/lib/mysql]          nodestack/recipes/mysql_add_drive.rb:51
        it 'creates the /var/lib/mysql directory' do
          expect(chef_run).to create_directory('/var/lib/mysql')
        end

        # mount[/var/lib/mysql]              nodestack/recipes/mysql_add_drive.rb:61
        it 'mounts the /var/lib/mysql drive' do
          expect(chef_run).to enable_mount('/var/lib/mysql')
          expect(chef_run).to mount_mount('/var/lib/mysql').with(fstype: 'ext3')
        end
      end
    end
  end
end
