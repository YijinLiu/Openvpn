# How to setup openvpn server on Ubuntu
=============================
## User docker
<pre>
$ make
</pre>
## Manually
### Install packages
<pre>
$ sudo apt-get install openvpn easy-rsa
</pre>
### Generate keys
<pre>
$ sudo bash
# cd /etc/openvpn
# cp -a /usr/share/easy-rsa .
# cd easy-rsa
# source vars
# ./clean-all
# ./build-ca
# ./build-key-server server
# ./build-dh
</pre>
### Configure openvpn
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
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "topology subnet"
topology subnet
keepalive 10 120
cipher AES-256-CBC
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 4
log-append /var/log/openvpn.log
</pre>
Test your configuration with:
<pre>
# openvpn server.conf
</pre>
## Configure client
<pre>
# ./build-key client1
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
&lt;ca&gt;
-----BEGIN CERTIFICATE-----
PASTE /etc/openvpn/easy-rsa/keys/ca.crt HERE
-----END CERTIFICATE-----
&lt;/ca&gt;
&lt;cert&gt;
-----BEGIN CERTIFICATE-----
PASTE /etc/openvpn/easy-rsa/keys/client1.crt HERE
-----END CERTIFICATE-----
&lt;/cert&gt;
&lt;key&gt;
-----BEGIN PRIVATE KEY-----
PASTE /etc/openvpn/easy-rsa/keys/client1.key HERE
-----END PRIVATE KEY-----
&lt;/key&gt;
ns-cert-type server
cipher AES-256-CBC
resolv-retry infinite
nobind
</pre>

## Enable internet access (optional):
<pre>
$ sudo sysctl -w net.ipv4.ip_forward=1
$ sudo iptables -A FORWARD -o eth0 -i tun0 -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT
$ sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$ sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
</pre>
## Disable VPN client access to LAN (optional):
You'll need to replace "192.168.1.0/24" with your own LAN address.
<pre>
$ sudo iptables -I INPUT -i tun0 -d 192.168.1.0/24 -j DROP
</pre>
## Auto start openvpn
<pre>
$ sudo update-rc.d openvpn enable
$ sudo service openvpn start
</pre>
