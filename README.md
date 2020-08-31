Elrond real-time node performance and health monitoring
powered by DisruptiveDigital 2020

In case you have other node charts scripts active please delete them all. You can check them here /usr/libexec/netdata/charts.d/. 
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


The alarms are configured as follows:

> Elrond node is not maintaining syncronization
- WARNING if out of sync more than 2:5 (hysteresis) consensus rounds
- CRITICAL if out of sync more than 100:200 (hysteresis) consensus rounds 

> Elrond node rate dropping
- WARNING if node rate is dropping under 100
- CRITICAL if node rate is dropping under 85

> Elrond node Leader blocks proposed versus block accepted dropping
- WARNING if leader blocks proposed versus blocks accepted are greater than 0
- CRITICAL if leader blocks proposed versus blocks accepted are greater than 10

> Elrond node Validator blocks signed versus blocks accepted dropping
- WARNING if validator blocks signed versus blocks accepted are greater than 2
- CRITICAL if validator blocks signed versus blocks accepted are greater than 20

> Elrond node peers dropping
- WARNING if peers are dropping under 40
- CRITICAL if peers are dropping under 30


Alarms can be configured with the following command:
cd /etc/netdata/health.d/ && sudo nano elrond.conf

Then,
sudo systemctl restart netdata
