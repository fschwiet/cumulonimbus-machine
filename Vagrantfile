# -*- mode: ruby -*-
# vi: set ft=ruby :

syncedFolder = ENV["SyncedFolder"] || nil
wwwuser = ENV["wwwuserUsername"] || "wwwuser"
wwwuserPassword = ENV["wwwuserPassword"] || "password"
mysqlRootPassword = ENV["mysqlRootPassword"] || ""

digitalOceanPrivateKeyPath = ENV["digitalOceanPrivateKeyPath"] || nil #  /path/id_rsa
digitalOceanProviderToken = ENV["digitalOceanProviderToken"] || nil

#  vagrantServerName is set for digitalocean to allow selection
#  of a particular droplet.  On migration to a new droplet, you
#  need to change this.

vagrantHostName = ENV["vagrantHostName"] || "default"

require "./util.rb"
require "./fschwiet.rb"


Vagrant.configure("2") do |config|

	config.vm.box = "opscode-ubuntu-14.04"
	config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
	megabytesMemoryInstalled = 512

	unless digitalOceanPrivateKeyPath.nil?
		config.vm.provider :digital_ocean do |provider, override|
			
			provider.ssh_key_name = "cumulonimbus-machine fschwiet"
			override.ssh.private_key_path = digitalOceanPrivateKeyPath
			
			override.vm.box = 'digital_ocean'
			override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

			provider.token = digitalOceanProviderToken
			provider.image = 'ubuntu-14-04-x64'
			provider.region = 'nyc2'
			provider.size = '512mb'
		end
	end
	
	config.omnibus.chef_version = "11.18"

	config.vm.network "private_network", ip: "192.168.33.100"
	
	unless syncedFolder.nil?
		config.vm.synced_folder File.absolute_path(syncedFolder), "/vagrant"
	else
		config.vm.synced_folder ".", "/vagrant", disabled: true
	end

	config.vm.provision "file", source: './host/', destination: '/tmp/cumulonimbus/host/'

	#  Copying the cookbooks since I couldn't get rsync to run on digitalocean.
	#  Only take the first result, because if rsync did succeed and its already copied
	#  then there are other cookbooks subfolders.

	config.vm.provision "file", source: './cookbooks/', destination: '/tmp/cumulonimbus/cookbooks/'
	config.vm.provision "shell", inline: 
		'cp -r /tmp/cumulonimbus/cookbooks/* $(find /tmp/vagrant-chef -name cookbooks | head --lines 1)'

	enableFirewall config.vm, [
		"3306/tcp",  #mysql
		"21/tcp",    #ftp, used by wget during some provisioning
		"22/tcp"     #ssh
	]

	protectFromBashBug config.vm
	protectSshFromLoginAttacks config.vm

	createSwapFileIfMissing config.vm, 2*megabytesMemoryInstalled

	aptgetUpdate config.vm

	config.vm.provision "shell", inline: "sudo apt-get install -y make"  # required by nodejs cookbook, was missing from DigitalOcean box

	installGit config.vm

	installNodejs config.vm

	config.vm.provision "shell", inline: "sudo apt-get install -y realpath"
	config.vm.provision "shell", inline: "sudo npm install pm2 -g --unsafe-perm"

	installNginx config.vm

	installMysql config.vm, mysqlRootPassword	

	# package ca-certificates-mono is called out in some mono docs but is not really available,
	# and seems to no longer be necessary
	# config.vm.provision "shell", inline: "sudo apt-get install -y ca-certificates-mono"
	
	config.vm.provision "shell", inline: "sudo apt-get install -y mono-complete" 
	config.vm.provision "shell", inline: "mozroots --import --sync" 
	
	config.vm.provision "shell", inline: "sudo apt-get install -y supervisor" 

	config.vm.provision "file", destination: "/tmp/cumulonimbus.sudoers", source: "./resources/cumulonimbus.sudoers"
	config.vm.provision "shell", inline: "visudo -f /tmp/cumulonimbus.sudoers -c"
	config.vm.provision "shell", inline: "chown root:root /tmp/cumulonimbus.sudoers"
	config.vm.provision "shell", inline: "chmod 0440 /tmp/cumulonimbus.sudoers"
	config.vm.provision "shell", inline: "mv /tmp/cumulonimbus.sudoers /etc/sudoers.d/cumulonimbus"

	config.vm.provision "shell", path: "./scripts/install-cumulonimbus.sh", args: [ 
		wwwuser, 
		wwwuserPassword
	]

	config.vm.define vagrantHostName
end


