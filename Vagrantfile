# -*- mode: ruby -*-
# vi: set ft=ruby :

syncedFolder = ENV["SyncedFolder"] || nil
wwwuser = ENV["wwwuserUsername"] || "wwwuser"
wwwuserPassword = ENV["wwwuserPassword"] || "password"

#  vagrantServerName is set for digitalocean to allow selection
#  of a particular droplet.  On migration to a new droplet, you
#  need to change this.

vagrantHostName = ENV["vagrantHostName"] || "default"

require "./util.rb"


Vagrant.configure("2") do |config|

	config.vm.box = "opscode-ubuntu-14.04"
	config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
	megabytesMemoryInstalled = 512

	config.omnibus.chef_version = "11.18"

	config.vm.network "private_network", ip: "192.168.33.100"
	
	unless syncedFolder.nil?
		config.vm.synced_folder File.absolute_path(syncedFolder), "/vagrant"
	end

	config.vm.provision "file", source: './host/', destination: '/tmp/cumulonimbus/host/'

	enableFirewall config.vm, [
		"21/tcp",    #ftp, used by wget during some provisioning
		"22/tcp"     #ssh
	]

	protectFromBashBug config.vm
	protectSshFromLoginAttacks config.vm

	createSwapFileIfMissing config.vm, 2*megabytesMemoryInstalled

	aptgetUpdate config.vm
	installGit config.vm

	installNodejs config.vm

	config.vm.provision "shell", inline: "sudo apt-get install -y realpath"
	config.vm.provision "shell", inline: "sudo npm install pm2 -g --unsafe-perm"

	installNginx config.vm

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


