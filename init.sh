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
