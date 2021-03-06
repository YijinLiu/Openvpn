WORK_DIR:=$(shell readlink -f $(dir $(lastword $(MAKEFILE_LIST))))

NAME?=server1
PORT?=1194

default:
	cd $(WORK_DIR)
	docker build -t $(USER)/openvpn:$(NAME) --build-arg NAME=$(NAME) --build-arg PORT=$(PORT) .
	docker run -dit --name openvpn-$(NAME) -p $(PORT):$(PORT)/udp --cap-add=NET_ADMIN --privileged -v $(HOME):$(HOME) $(USER)/openvpn:$(NAME)
	docker exec openvpn-$(NAME) bash -c "sysctl -w net.ipv4.ip_forward=1"
	docker exec openvpn-$(NAME) bash -c "iptables -A FORWARD -o eth0 -i tun0 -s 10.8.0.0/24 -m conntrack --ctstate NEW -j ACCEPT"
	docker exec openvpn-$(NAME) bash -c "iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT"
	docker exec openvpn-$(NAME) bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
	docker exec openvpn-$(NAME) bash -c "service openvpn start"
