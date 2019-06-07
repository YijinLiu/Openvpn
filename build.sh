#!/bin/bash

set -e

name=server1
port=1194
OPTS=`getopt -n 'build.sh' -o n:p: -l name:,port: -- "$@"`
eval set -- "$OPTS"
while true; do
    case "$1" in
        -n | --name )     name="$2" ; shift 2 ;;
        -p | --port )     port="$2" ; shift 2 ;;
        -- ) shift; break ;;
        * ) echo -e "${RED}Invalid option: -$1${NC}" >&2 ; exit 1 ;;
    esac
done

cp -a /usr/share/easy-rsa /etc/openvpn/
ln -sf openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
cd /etc/openvpn/easy-rsa
source ./vars
./clean-all
./pkitool --initca
./pkitool --server $name
./build-dh
echo "port $port
proto udp
dev tun
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/$name.crt
key /etc/openvpn/easy-rsa/keys/$name.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push 'redirect-gateway def1'
push 'dhcp-option DNS 8.8.8.8'
push 'topology subnet'
topology subnet
keepalive 10 120
cipher AES-256-CBC
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 4
log-append /var/log/openvpn/$name.log" > /etc/openvpn/$name.conf
update-rc.d openvpn enable
