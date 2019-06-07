#!/bin/bash

set -e

ip=YOUR_IP
name=client1
port=1194
OPTS=`getopt -n 'build.sh' -o i:n:p: -l ip:,name:,port: -- "$@"`
eval set -- "$OPTS"
while true; do
    case "$1" in
        -i | --ip )       ip="$2" ; shift 2 ;;
        -n | --name )     name="$2" ; shift 2 ;;
        -p | --port )     port="$2" ; shift 2 ;;
        -- ) shift; break ;;
        * ) echo -e "${RED}Invalid option: -$1${NC}" >&2 ; exit 1 ;;
    esac
done

cd /etc/openvpn/easy-rsa
source ./vars
./pkitool ${name}

start=`awk '/-----BEGIN CERTIFICATE-----/{ print NR; exit }' keys/$name.crt`
tail -n $start keys/$name.crt
echo "client
dev tun
proto udp
remote $ip $port
float
comp-lzo adaptive
keepalive 10 120
<ca>
$(cat keys/ca.crt)
</ca>
<cert>
$(tail -n +$start keys/$name.crt)
</cert>
<key>
$(cat keys/$name.key)
</key>
ns-cert-type server
cipher AES-256-CBC
resolv-retry infinite
nobind" > keys/$name.ovpn

echo -e "\033[0;32mCreated /etc/openvpn/easy-rsa/keys/$name.ovpn\033[0m"
