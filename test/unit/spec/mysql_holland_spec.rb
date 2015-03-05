# Encoding: utf-8

require_relative 'spec_helper'

describe 'nodestack::mysql_holland' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        packages = %w(
          holland
          holland-mysqldump
        )
        it 'installs packages' do
          packages.each do |package|
            expect(chef_run).to install_package(package)
          end
        end

        # apt_repository[Holland]            nodestack/recipes/mysql_holland.rb:25
        # yum_repository[Holland]            nodestack/recipes/mysql_holland.rb:33
        it 'creates the holland repo' do
          if platform == 'ubuntu'
            expect(chef_run).to add_apt_repository('Holland')
          elsif platform == 'centos'
            expect(chef_run).to create_yum_repository('Holland')
          end
        end

        # template[/etc/holland/backupsets/default.conf]   nodestack/recipes/mysql_holland.rb:61
        it 'creates the holland config' do
          expect(chef_run).to create_template('/etc/holland/backupsets/default.conf')
        end

        # cron[backup]                       nodestack/recipes/mysql_holland.rb:74
        it 'creates the holland cron' do
          expect(chef_run).to create_cron('backup')
        end
      end
    end
  end
end
