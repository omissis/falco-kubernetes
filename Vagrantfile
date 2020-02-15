# -*- mode: ruby -*-
# vi: set ft=ruby :

# Function to check whether VM was already provisioned
def provisioned?(vm_name="default", provider="virtualbox")
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.ssh.insert_key = false
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :virtualbox do |v|
    v.memory = 1536
    v.cpus = 1
    v.linked_clone = true
    v.customize ["modifyvm", :id, "--audio", "none"]
  end

  if ENV["K8S_MODE"] == "multi"
    boxes = [
      { :name => "kube1", :ip => "192.168.10.2", :ssh_port => 6622 },
      { :name => "kube2", :ip => "192.168.10.3", :ssh_port => 6623 },
      { :name => "kube3", :ip => "192.168.10.4", :ssh_port => 6624 }
    ]
  else
    boxes = [
      { :name => "kube1", :ip => "192.168.10.2", :ssh_port => 6622 }
    ]
  end

  new_hostnames = boxes.reduce("") { |hostnames, box| hostnames + box[:ip] + " " + box[:name] + "\n" }

  boxes.each do |box|
    config.vm.define box[:name] do |config|
      config.vm.hostname = box[:name]
      config.vm.network :private_network, ip: box[:ip]
      config.vm.provision "shell", path: "./packer/aws.ubuntu-18-04.sh"
      config.vm.provision "shell", inline: "echo '" + new_hostnames + "' >> /etc/hosts"
      config.vm.provision "shell", inline: 'echo "sudo su -" >> .bashrc'

      if provisioned?(box[:name])
        config.vm.network "forwarded_port", guest: 10022, host: box[:ssh_port]
        config.ssh.port = box[:ssh_port]
      end
    end
  end
end
