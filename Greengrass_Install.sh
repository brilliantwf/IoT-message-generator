#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt upgrade -y
apt install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa -y
apt update -y
apt install python3.8 python3.8-gdbm python3.8-distutils -y
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2
update-alternatives --set python3 /usr/bin/python3.8
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py 
python3 -m pip install greengrasssdk
adduser --system ggc_user
groupadd --system ggc_group
# Install Greengrass via APT repository (suitable for testing)
wget -O aws-iot-greengrass-keyring.deb
https://d1onfpft10uf5o.cloudfront.net/greengrass-apt/downloads/aws-iot-greengrass-keyring.deb
dpkg -i aws-iot-greengrass-keyring.deb
echo "deb https://dnw9lb6lzp2d8.cloudfront.net stable main" | sudo tee
/etc/apt/sources.list.d/greengrass.list
apt update -y
apt install aws-iot-greengrass-core -y
echo -n "${IoTThing.certificatePem}" >
/greengrass/certs/${IoTThing.certificateId}.pem
echo -n "${IoTThing.privateKey}" >
/greengrass/certs/${IoTThing.certificateId}.key
cd /greengrass/config
# Create Greengrass config file from inputs and parameters
# Can be enhanced to manage complete installation of Greengrass and
credentials
cat <<EOT > config.json          
{
  "coreThing" : {
    "caPath" : "root.ca.pem",
    "certPath" : "${IoTThing.certificateId}.pem",
    "keyPath" : "${IoTThing.certificateId}.key",
    "thingArn" : "arn:aws:iot:${AWS::Region}:${AWS::AccountId}:thing/${CoreName}_Core",
    "iotHost" : "${IoTThing.iotEndpoint}",
    "ggHost" : "greengrass-ats.iot.${AWS::Region}.amazonaws.com"
  },
  "runtime" : {
    "cgroup" : {
      "useSystemd" : "yes"
    }
  },
  "managedRespawn" : false,
  "crypto" : {
    "principals" : {
      "SecretsManager" : {
        "privateKeyPath" : "file:///greengrass/certs/${IoTThing.certificateId}.key"
      },
      "IoTCertificate" : {
        "privateKeyPath" : "file:///greengrass/certs/${IoTThing.certificateId}.key",
        "certificatePath" : "file:///greengrass/certs/${IoTThing.certificateId}.pem"
      }
    },
    "caPath" : "file:///greengrass/certs/root.ca.pem"
  }
}
EOT
cd /greengrass/certs/
wget -O root.ca.pem
https://www.amazontrust.com/repository/AmazonRootCA1.pem
cd /tmp
# Create Greengrass systemd file - thanks to:
https://gist.github.com/matthewberryman/fa21ca796c3a2e0dfe8224934b7b055c
cat <<EOT > greengrass.service
[Unit]
Description=greengrass daemon
After=network.target
[Service]
ExecStart=/greengrass/ggc/core/greengrassd start
Type=simple
RestartSec=2
Restart=always
User=root
PIDFile=/var/run/greengrassd.pid
[Install]
WantedBy=multi-user.target
EOT
cp greengrass.service /etc/systemd/system
systemctl enable greengrass.service
mkdir -p /shared/greengrass/buffer
sudo chown -R ggc_user:ggc_group /shared/greengrass/buffer/
sudo wget -cO -
https://pdm-workshop-ue1.s3.amazonaws.com/rawdata/iotdata.csv
>/shared/greengrass/buffer/iotdata.csv 
reboot