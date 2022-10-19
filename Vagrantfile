# -*- mode: ruby -*-
# vi: set ft=ruby :

$provisionScript = <<-SCRIPT
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y wget openjdk-11-jdk
mkdir /opt/rundeck
wget --quiet -O /opt/rundeck/rundeck.war https://packagecloud.io/pagerduty/rundeck/packages/java/org.rundeck/rundeck-4.6.1-20220914.war/artifacts/rundeck-4.6.1-20220914.war/download
export RDECK_BASE=/opt/rundeck
pushd /opt/rundeck
sudo java -Xmx4g -jar /opt/rundeck/rundeck.war --installonly
popd
sudo sed -i 's/server\.address=localhost/server\.address=0\.0\.0\.0/g' /opt/rundeck/server/config/rundeck-config.properties
sudo mv /home/vagrant/rundeck.service /etc/systemd/system
sudo systemctl enable rundeck.service
sudo systemctl start rundeck.service
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "rundeckautomation" do |rd|
    rd.vm.hostname = "vagrant-rundeck"

    rd.vm.box = "ubuntu/focal64"

    rd.vm.network "forwarded_port", guest: 4440, host: 4440, auto_correct: true

    rd.vm.provider "virtualbox" do |vm|
      vm.memory = 4096
      vm.cpus = 2
      vm.gui = false
    end
  end

  config.vm.provision "file", source: "./vagrant/rundeck.service", destination: "~/rundeck.service"
  config.vm.provision "shell", inline: $provisionScript

  config.trigger.after [:up, :resume] do |trigger|
    trigger.info = "Rundeck UI should be available at http://127.0.0.1:4440.  Confirm port mapping with 'vagrant port rundeckautomation'."
  end

end
