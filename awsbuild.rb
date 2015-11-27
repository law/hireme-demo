#!/usr/bin/env ruby
require 'fog'
require 'inifile'
require 'pry'

def getauth
  # Load up the AWS ini files and combine them by profile into one 'auth' hash
  creds_file = File.expand_path("~/.aws/credentials")
  creds = File.exists?(creds_file) ? IniFile.load(creds_file) : { 'DEFAULT' => {} }
  prefs_file = File.expand_path("~/.aws/config")
  prefs = File.exists?(prefs_file) ? IniFile.load(prefs_file) : { 'DEFAULT' => {} }
  prefs.merge(creds).to_h
end

def upload_key
  # Reads in ~/.ssh/id_rsa.pub and uploads it to AWS for the purposes of the 
  # demo
  @connection.import_key_pair('law-demo-key', IO.read(File.expand_path("~/.ssh/id_rsa.pub"))) if @connection.key_pairs.get('law-demo-key').nil?  
end

def cleanup(server)
  puts "Waiting for VM to fully delete"
  server.destroy
  server.wait_for { state == "terminated" }

  puts "Removing key-pair"
  @connection.delete_key_pair('law-demo-key')
 
  puts "Removing security group" 
  begin
    @connection.delete_security_group('law-demo-1')
  rescue 
    puts (<<EOS)
  Exception raised trying to remove the security group.
  Perhaps another VM named 'law-demo1' is in the environment and associated with this security group?

  Cowardly refusing to proceed (and possibly gleefully thrash a pre-existing setup).  Regrettably, manual removal of demo resources will be needed at this time.
EOS
  end

  puts "All clean!"
end

def bootstrap(server)
  # Takes a provisioned VM-object and bootstraps it via Puppet
  puts "Bootstrap begin" 

  begin
    puts "Installing Puppet"
    server.ssh('sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm')
    server.ssh('sudo yum install puppet3 git -y')

    puts "Cloning project repo" 
    server.ssh('sudo git clone https://github.com/law/hireme-demo.git /root/demo')

    puts "Puppetizing machine"
    server.ssh('sudo puppet apply --modulepath=/root/demo/puppet/modules/ -e "include httpd"')

  rescue Net::SSH::ConnectionTimeout, Errno::ECONNREFUSED

    puts "Ssh timeout or refused connection, server is probably still booting.  Sleeping 20 seconds and retrying."
    sleep(20) 
    puts "Retrying..."
    retry 
  end 
end

# Fire up our AWS connection object; this can now be passed around 
# for various and sundry tasks
auth = getauth
@connection = Fog::Compute.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => auth['default']['aws_access_key_id'],
  :aws_secret_access_key    => auth['default']['aws_secret_access_key'],
  :region		    => auth['default']['region']
})

# Create simple security group 
begin
  sg = @connection.security_groups.new(
    :name => "law-demo-1",
    :description => "LAW demo for Stelligent"
  )
  sg.save # Yes, this has to happen before we can assign port ranges...
  sg.authorize_port_range(22..22, {:cidr_ip => "0.0.0.0/0"})
  sg.authorize_port_range(80..80, {:cidr_ip => "0.0.0.0/0"})
rescue Fog::Compute::AWS::Error
  puts "Security Group seems to already exist"
end

# read in ~/.ssh/id_rsa.pub and upload it to AWS  
upload_key

# Create initial instance of our server; apologies for the 
# hard-coded parameters.  
server = @connection.servers.create(:tags => {"Name" => "law-demo1"},
  :key_name => "law-demo-key",
  :groups => "law-demo-1",
  :image_id => "ami-d5ea86b5",
  :flavor_id => "t2.micro",
  :username => 'ec2-user'
)

puts "Waiting for server to provision..." 
server.wait_for { ready? }

# Once VM is 'ready', bootstrap the VM via ssh commands and puppet
bootstrap(server)


# 'Magic' is complete.  Now have a friendly prompt for whomever is driving
# console...
puts(<<EOS)
  *********************************

  Congratulations!  The demo server has been provisioned, bootstrapped, and 
  initialized.  Unless something is deeply, terribly wrong, you should be 
  able to browse to

  http://#{server.public_ip_address}

  and access the demo site.  If you would like to ssh to the instance 

    $ ssh #{server.username}@#{server.public_ip_address} 

  will get you a terminal on the host.  You can type 'cleanup' at the prompt to 
  automatically delete the VM, security group, and uploaded public key, 'exit'
  to exit, or ctrl-C to quit.  Latter two options will still leave VMs, etc, 
  running, which may incur additional AWS charges.   

  Finally, if you would like to run serverspec tests against the host, please
  add the following to your ~/.ssh/config before running 'rake spec':

    Host law-demo1
      hostname #{server.public_ip_address}
    
  **********************************
EOS

begin
puts "Prompt $ "
input = gets.chomp
  case input
  when "cleanup"
    cleanup(server)
  when "exit"
    exit 0
  when "pry"
    binding.pry
  else
    puts "Must be 'cleanup', 'exit', or you can always ctrl-C" 
    raise TypeError
  end
rescue TypeError 
  retry
end
