# -*- mode: ruby -*-
# rsync patterns
vagrant_ignore = [
    'bin*',
    'pkg*',
    'spec/fixtures*',
]

Vagrant.configure("2") do |config|
    config.vagrant.plugins = ["vagrant-vbguest"]
    config.vm.network "private_network", type: "dhcp", name: "vboxnet0"
    config.vbguest.auto_update = false

    config.vm.define "ipa-server-1" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "2004.01"
        # Exclude certain directories to avoid issues
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-server-1.vagrant.example.lan'
        # Assign this VM to a host-only network IP, allowing you to access it
        # via the IP.
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1536
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        # Fix Virtualbox Guest Additions installation issue
        # https://github.com/hashicorp/vagrant/issues/12095
        box.vbguest.installer_options = { allow_kernel_upgrade: true }
        box.vm.network "private_network", ip: "192.168.56.35"
        box.vm.network "forwarded_port", guest: 8000, host: 8000
        box.vm.network "forwarded_port", guest: 8440, host: 8440
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        # common.sh synchronizes latest code, so do not disable it while testing
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos.sh"
        box.vm.provision "shell", path: "vagrant/ipa-server-1.sh"
    end

    config.vm.define "ipa-server-2" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "2004.01"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-server-2.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1536
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vbguest.installer_options = { allow_kernel_upgrade: true }
        box.vm.network "private_network", ip: "192.168.56.36"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos.sh"
        box.vm.provision "shell", path: "vagrant/ipa-server-2.sh"
    end

    config.vm.define "ipa-client-1" do |box|
        box.vm.box = "centos/7"
        box.vm.box_version = "2004.01"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-1.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vbguest.installer_options = { allow_kernel_upgrade: true }
        box.vm.network "private_network", ip: "192.168.56.37"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/centos.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-2" do |box|
        box.vm.box = "ubuntu/xenial64"
        box.vm.box_version = "20211001.0.0"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-2.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.56.38"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-3" do |box|
        box.vm.box = "ubuntu/trusty64"
        box.vm.box_version = "20190514.0.0"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-3.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.56.39"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-4" do |box|
        box.vm.box = "generic/debian9"
        box.vm.box_version = "4.0.0"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-4.vagrant.example.lan'
        box.vbguest.installer_options = { allow_kernel_upgrade: true }
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.56.40"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-5" do |box|
        box.vm.box = "ubuntu/bionic64"
        box.vm.box_version = "20220424.0.0"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-5.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.56.41"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-6" do |box|
      box.vm.box = "generic/debian10"
      box.vm.box_version = "4.0.0"
      box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
      box.vm.hostname = 'ipa-client-6.vagrant.example.lan'
      box.vbguest.installer_options = { allow_kernel_upgrade: true }
      box.vm.provider 'virtualbox' do |vb|
        vb.customize ["modifyvm", :id, "--natnet1", "172.31.10/24"]
        vb.gui = false
        vb.memory = 1024
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--hpet", "on"]
      end
      box.vm.network "private_network", ip: "192.168.56.42"
      box.vm.provision "shell", path: "vagrant/install-puppet.sh"
      box.vm.provision "shell", path: "vagrant/common.sh"
      box.vm.provision "shell", path: "vagrant/debian.sh"
      #box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-7" do |box|
      box.vm.box = "generic/debian11"
      box.vm.box_version = "4.0.0"
      box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
      box.vm.hostname = 'ipa-client-7.vagrant.example.lan'
      box.vbguest.installer_options = { allow_kernel_upgrade: true }
      box.vm.provider 'virtualbox' do |vb|
        vb.customize ["modifyvm", :id, "--natnet1", "172.31.10/24"]
        vb.gui = false
        vb.memory = 1024
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--hpet", "on"]
      end
      box.vm.network "private_network", ip: "192.168.56.43"
      box.vm.provision "shell", path: "vagrant/install-puppet.sh"
      box.vm.provision "shell", path: "vagrant/common.sh"
      box.vm.provision "shell", path: "vagrant/debian.sh"
      box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end

    config.vm.define "ipa-client-8" do |box|
        box.vm.box = "ubuntu/jammy64"
        box.vm.box_version = "20220419.0.0"
        box.vm.synced_folder '.', '/vagrant', type: "rsync", rsync__auto: true, rsync__exclude: vagrant_ignore
        box.vm.hostname = 'ipa-client-8.vagrant.example.lan'
        box.vm.provider 'virtualbox' do |vb|
            vb.customize ["modifyvm", :id, "--natnet1", "172.31.9/24"]
            vb.gui = false
            vb.memory = 1024
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--hpet", "on"]
        end
        box.vm.network "private_network", ip: "192.168.56.44"
        box.vm.provision "shell", path: "vagrant/install-puppet.sh"
        box.vm.provision "shell", path: "vagrant/common.sh"
        box.vm.provision "shell", path: "vagrant/debian.sh"
        box.vm.provision "shell", path: "vagrant/ipa-client.sh"
    end
end
