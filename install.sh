#!/usr/bin/env bash
WORKDIR=$(dirname "$(realpath "$0")")
SERVICE="python-ip-announcer"
TARGET="/usr/bin/$SERVICE"

echo "Installing $SERVICE..."

if [ $(whoami) != "root" ]
then
  echo "Please run as root!"
  exit 1
fi

apt update
apt install python python-paho-mqtt python-netifaces --yes

cp $WORKDIR/$SERVICE $TARGET
chmod +x $TARGET

echo "Create systemd service file"
echo "[Unit]
Description=$SERVICE daemon
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
Restart=never
StartLimitIntervalSec=5
ExecStart=$(which python) $TARGET

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/$SERVICE.service


echo "Reload daemon"
systemctl daemon-reload

echo "Enable $SERVICE"
systemctl enable $SERVICE.service

echo "Restart $SERVICE"
systemctl restart $SERVICE.service

echo "Done."

systemctl status $SERVICE.service
