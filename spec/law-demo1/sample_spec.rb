require 'spec_helper'

describe package('httpd') do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe port(22) do
  it { should be_listening }
end

describe package('webapp') do
  it { should be_installed }
end

describe package('puppet3') do
  it { should be_installed }
end

describe package('git') do
  it { should be_installed }
end

describe file('/etc/httpd/sites-enabled/httpd_vhost.conf') do
  it { should be_file }
  its(:content) { should match /ServerName law-demo/ }
  # its(:content) { should match /ServerName ['"]#{RSpec.configuration.host}['"]{0,1}/ }
end

describe yumrepo('puppetlabs-pc1-source') do
  it { should exist }
end

describe command('curl -s localhost') do
  its(:stdout) { should contain('Automation For The People') }
end
