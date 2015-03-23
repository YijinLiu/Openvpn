# How to setup openvpn server on Ubuntu
=============================
## Install packages
<pre>
$ sudo apt-get install openvpn easy-rsa
</pre>
## Generate keys
<pre>
$ sudo bash
# cd /etc/openvpn
# cp -a /usr/share/easy-rsa .
# cd easy-rsa
# source vars
# ./clean-all
# ./build-ca
# ./build-key-server server
# ./build-key client1
# ./build-dh
</pre>
## Configure openvpn
<pre>
# cd /etc/openvpn
# vi server.conf
</pre>
Paste the following:
<pre>
port 1194
proto udp
dev tun
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
</pre>
Test your configuration with:
<pre>
# openvpn server.conf
</pre>
## Configure client
<pre>
# vi client1.ovpn
</pre>
Paste the following:
<pre>
client
dev tun
proto udp
remote YOUR-IP 1194
float
comp-lzo adaptive
keepalive 10 120
auth-user-pass
<ca>
-----BEGIN CERTIFICATE-----
PASTE /etc/openvpn/easy-rsa/keys/ca.crt HERE
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
PASTE /etc/openvpn/easy-rsa/keys/client1.crt HERE
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
PASTE /etc/openvpn/easy-rsa/keys/client1.key HERE
-----END PRIVATE KEY-----
</key>
ns-cert-type server
cipher AES-256-CBC
resolv-retry infinite
nobind
</pre>
## Enable internet access (optional):
<pre>
$ sudo sysctl -w net.ipv4.ip_forward=1
</pre>
## Disable VPN client access to LAN (optional):
<pre>
# You might need to 192.168.1.0 with your own LAN address.
sudo iptables -I INPUT -i tun0 -d 192.168.1.0/24 -j DROP
</pre>
