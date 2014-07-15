# Encoding: utf-8

require_relative 'spec_helper'

describe port(8080) do
  it { should be_listening }
end

describe port(3306) do
  it { should be_listening }
end