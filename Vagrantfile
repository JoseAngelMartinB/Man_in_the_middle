# -*- mode: ruby -*-
# vi: set ft=ruby :

# Man in the middle attack
# https://github.com/JoseAngelMartinB/Man_in_the_middle
# Autores:
#  - José Ángel Martín Baos
#  - Óscar Pérez Galán

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant_data"

  config.vm.define "router" do |router|
    router.vm.box = "ubuntu/xenial64"
    router.vm.hostname = "router"
    #router.vm.network "public_network"
    router.vm.network "private_network", ip: "192.168.5.1", virtualbox__intnet: true
    router.vm.provider :virtualbox do |vb|
        vb.name = "router"
        vb.memory = "1024"
    end
    # Configurar la red
    router.vm.provision "shell", run: "always", inline: <<-SHELL
      sudo echo 1 > /proc/sys/net/ipv4/ip_forward
      sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
    SHELL
  end

  config.vm.define "victima" do |victima|
    victima.vm.box = "chad-thompson/ubuntu-trusty64-gui"
    victima.vm.hostname = "victima"
    victima.vm.network "private_network", ip: "192.168.5.2", :auto_config => "false", :netmask => "255.255.255.0", virtualbox__intnet: true
    victima.vm.provider :virtualbox do |vb|
        vb.name = "victima"
        vb.memory = "1024"
	vb.gui = true
	vb.customize [ "setextradata", :id, "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", 1 ]
    end
    # Configurar la red
    victima.vm.provision "shell", run: "always", inline: "sudo ifconfig eth1 192.168.5.2 netmask 255.255.255.0 up"
    victima.vm.provision "shell", run: "always", inline: "sudo route del default"
    victima.vm.provision "shell", run: "always", inline: "sudo route add default gw 192.168.5.1"
	victima.vm.provision "shell", run: "always", inline: "localectl set-keymap es"
  end

  config.vm.define "atacante" do |atacante|
    atacante.vm.box = "ubuntu/xenial64"
    atacante.vm.hostname = "atacante"
    atacante.vm.network "private_network", ip: "192.168.5.3", virtualbox__intnet: true
    atacante.vm.provider :virtualbox do |vb|
        vb.name = "atacante"
        vb.memory = "1024"
    end
    # Configurar la red
    atacante.vm.provision "shell", run: "always", inline: "sudo route del default"
    atacante.vm.provision "shell", run: "always", inline: "sudo route add default gw 192.168.5.1"
  end

end
