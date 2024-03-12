# -*- mode: ruby -*-
# vi: set ft=ruby :

$provisionScript = <<-SCRIPT
env
set
sudo echo deb http://deb.debian.org/debian unstable main non-free contrib >> /etc/apt/sources.list
sudo mv /home/vagrant/preferences /etc/apt/preferences
sudo apt-get update
# sudo apt-get upgrade -y > /dev/null
sudo apt-get install openjdk-11-jre -y > /dev/null
java --version
retVal=$?
if [ $retVal -ne 0 ]; then
  echo "No Java"
  exit -1
fi
mkdir /opt/rundeck
wget --quiet -O /opt/rundeck/rundeck.war https://packagecloud.io/pagerduty/rundeck/packages/java/org.rundeck/rundeck-4.17.5-20240304.war/artifacts/rundeck-4.17.5-20240304.war/download
export RDECK_BASE=/opt/rundeck
pushd /opt/rundeck
sudo java -Xmx4g -jar /opt/rundeck/rundeck.war --installonly
popd
host_ip=`hostname -I | xargs`
replace_localhost="s/localhost/$host_ip/g"
sudo sed -i 's/server\.address=localhost/server\.address=0\.0\.0\.0/g' /opt/rundeck/server/config/rundeck-config.properties
sudo mv /home/vagrant/rundeck.service /etc/systemd/system
sudo systemctl enable rundeck.service
sudo systemctl start rundeck
max_loop=10
while [ ! -f /opt/rundeck/etc/framework.properties ] && [ $max_loop -gt 0 ]; do
  echo 'Waiting for startup to complete.  Pausing 30 seconds.'
  sleep 30
  max_loop=$(( max_loop - 1 ))
done
if [ ! -f /opt/rundeck/etc/framework.properties ]; then
  echo 'Rundeck startup and initial configuration appears to have failed.'
  exit -1
fi
echo ${VAGRANT_PROVIDER}
if [ -n "${VAGRANT_PROVIDER}" ]; then
  sudo sed -i $replace_localhost /opt/rundeck/server/config/rundeck-config.properties
  sudo sed -i $replace_localhost /opt/rundeck/etc/framework.properties
  sudo systemctl restart rundeck
fi
sleep 30 # Make sure it doesn't just stop
systemctl status rundeck.service
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "rundeckautomation" do |rd|
    rd.vm.hostname = "vagrant-rundeck"

    rd.vm.box = "generic/debian12"

    rd.vm.network "forwarded_port", guest: 4440, host: 4440, auto_correct: true

    rd.vm.provider "hyperv" do |vm, override|
      override.vm.network "public_network", bridge: "Default Switch"
    end
  end

  config.vm.provision "file", source: "./vagrant/rundeck.service", destination: "~/rundeck.service"
  config.vm.provision "file", source: "./vagrant/preferences", destination: "~/preferences"
  config.vm.provision "shell", inline: $provisionScript, env: { "VAGRANT_PROVIDER" => ENV['VAGRANT_DEFAULT_PROVIDER'] }
end
