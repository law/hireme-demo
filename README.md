# awsbuild.rb

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with the script](#setup)
    * [What awsbuild.rb affects](#what-awsbuild-affects)
    * [Setup requirements](#setup-requirements)
    * [Running The Thing](#running-the-thing)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview

awsbuild.rb connects to AWS with the Fog library, creates a VM per the project description, provisions it via Puppet to display the proscribed webpage, and displays various connection information that may be of use to the user.  It's not quite idiot-proof, there are some strict setup requirements as detailed below.  

## Setup

### What awsbuild affects

* awsbuild will connect with your AWS credentials and create a standalone EC2 t2.tiny VM with them.  If you have a pre-existing key named 'law-demo-key', or a security group named 'law-demo-1' that doesn't at least allow inbound port 22 and port 80 TCP (as well as 'general' outbound connectivity, things might get real weird real quick.

* awsbuild may gleefully overwrite conflicting VM, security group, or keypair information it thinks it's namespaced for.  The 'cleanup' function will delete anything it thinks is demo-fodder (VMs named 'law-demo1', keypairs named 'law-demo-key', security groups named 'law-demo-1', etc).  Try to avoid using this with your 'production' or 'sales demo' AWS credentials if possible.  

* awsbuild expects there to be valid ~/.aws/config and ~/.aws/credentials ini files, with at least an 'access_key_id', 'secret_access_key', and 'region' specified in the 'default' profile.  The first two are mandatory, 'region' will default to 'us-east-1' if not defined.  

* awsbuild expects there to be a valid ssh keypair at ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub.  It will read your public key and upload it to AWS as 'law-demo-key'

* This software should be considered barely alpha, and of 'wrote it while in a turkey coma', 'It Works For Me(tm)' quality.  Applicant is not responsible for wildly unexpected behavior vis a vis nuking important other VMs, running up your AWS bill, kicking your dog, kissing your sister, or making your coffee wrong.  It should NOT BE TRUSTED with your 'production', 'sales demo', or 'kinda sorta somewhat important' AWS credentials.  

### Setup Requirements 

  As mentioned before, awsbuild wants a valid ~/.aws/config and ~/.aws/credentials file, as well as a valid ssh keypair at ~/.ssh/id_rsa.pub and ~/.id_rsa.  It was written with Ruby 2.1.2 under RVM on a Mac (OS X El Capitan), but a reasonably modern (Ruby >= 2.0) POSIX system should be fine.  Please run 'bundle install' in the project root so all the assorted gem requirements will install.   

### Running The Thing

  Presuming your ~/.aws/{config,credentials}, ~/.ssh/id_rsa, and ~/.ssh/id_rsa.pub are sorted, and that you've got a reasonably modern Ruby with a more or less clean gemset library, you should be able to run 'bundle install' in the project root, then './awsbuild.rb'.  Let it plug n' chug for a minute, and you'll get a prompt with VM connection information, the option to clean up the demo stuff, information on setting up your ~/.ssh/config for running serverspec tests, and/or exit.  

## Limitations

  awsbuild.rb presumes a reasonably complete POSIX environment and modern Ruby development environment (Ruby > 2.0, bundle-and-gem-install capability, etc) and outbound TCP ports 22, 80, and 443.  Definitely works on OS X El Capitan, probably works on most Linuxen, I would die of shock if it ran under Windows.  
