# Encoding: utf-8
require_relative 'spec_helper'

describe user('my_nodejs_app') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

describe file('/home/my_nodejs_app/.npm') do
  it { should be_owned_by 'my_nodejs_app' }
  it { should be_grouped_into 'my_nodejs_app' }
  it { should be_directory }
  it { should be_mode 755 }
end

describe file('/home/my_nodejs_app/.ssh/config') do
  its('content') { should match 'StrictHostKeyChecking false' }
end

describe port(80) do
  it { should be_listening }
end

describe file('/var/app/current/config.js') do
  it { should be_file }
end

describe service('my_nodejs_app') do
  it { should be_enabled }
  it { should be_running }
end

describe process('node') do
  it { should be_running }
  its('args') { should match 'server.js|app.js' }
end
