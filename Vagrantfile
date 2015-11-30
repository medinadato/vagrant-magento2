# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "app" do |app|
    app.vm.box = "ubuntu/trusty64"

    app.vm.network "private_network", ip: "100.0.0.40"

    app.vm.synced_folder "./www", "/vagrant/www/"
    app.vm.synced_folder "./provision", "/vagrant/provision/"

    config.ssh.forward_agent = true

    app.vm.provider "virtualbox" do |vb|
      vb.name = "box-resumise.com.au"
      vb.memory = "2048"
    end

    app.vm.provision "shell", path: "provision.sh"
  end
end
