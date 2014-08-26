#!/bin/bash

set -e

username=${1:?"Expected web app username as first parameter."}
password=${2:?"Expected web app password as second parameter."}
host_repository=${3:?"Expected host repository as third parameter."}
host_repository_commit=${4:?"Expected host repository commit id as fourth parameter."}

sudo useradd -m -c "Web Applications Account" -p $(openssl passwd -1 "$password") "$username"
sudo mkdir /cumulonimbus
git clone -b $host_repository_commit $host_repository /cumulonimbus
sudo chown --recursive "$username:$username" /cumulonimbus

echo '@reboot wwwuser PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin bash -c "cd /cumulonimbus; ./scripts/run-on-reboot.sh >>~/cronrun_cumulonimbus 2>&1"' | sudo tee /etc/cron.d/cumulonimbus > /dev/null

echo "To deploy an individual site, do something like:"
echo "    su $username"
echo "    git clone <project_repository> /cumulonimbus/sites/sample"
echo "    cumulonimbusMapHostnamePort.sh www.192.168.33.100.xip.ip 80 localhost 8080"
echo "    mkdir /cumulonimbus/sites/sample.config"
echo "    cp <config file> /cumulonimbus/sites/sample.config/config.json"
echo "    ln --symbolic /cumulonimbus/sites/sample.config /cumulonimbus/configs/sample"
echo "    cd /cumulonimbus"
echo "    ./deploy.sh sample"
