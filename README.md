Elrond real-time node performance and health monitoring
powered by DisruptiveDigital 2020

In case you have other node charts active please delete them all. You can check them here /usr/libexec/netdata/charts.d/. 
Example:
cd /usr/libexec/netdata/charts.d/ && ls
sudo rm sync.chart.sh


Commands on server:

mkdir -p ~/custom_netdata && cd ~/custom_netdata

git clone https://github.com/disruptivedigital/Elrond-node-netdata-monitoring.git

sudo systemctl stop netdata && cd /var/cache/netdata && sudo rm -rf *

sudo cp ~/custom_netdata/Elrond-node-netdata-monitoring/elrond.chart.sh /usr/libexec/netdata/charts.d/ && sudo cp ~/custom_netdata/Elrond-node-netdata-monitoring/elrond.conf /etc/netdata/health.d/

Edit config charts.d.conf:
sudo nano /etc/netdata/edit-config charts.d.conf

Add the following:
enable_all_charts="yes"
elrond="yes"

cd /usr/libexec/netdata/charts.d/ && sudo chmod +x elrond.chart.sh && sudo chmod 755 elrond.chart.sh

sudo systemctl restart netdata
