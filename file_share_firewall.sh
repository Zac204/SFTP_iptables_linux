echo "Flushing all chains"
iptables -F

echo "Setting default policy to DROP"
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
iptables -P INPUT DROP

echo "Allowing anything marked RELATED/ESTABLISHED"
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT -m comment --comment "ACCEPT incoming RELATED/ESTABLISHED"
iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT -m comment --comment "ACCEPT outgoing RELATED/ESTABLISHED"

echo "Allowing everything on loopback"
iptables -A INPUT -s 127.0.0.1 -j ACCEPT -m comment --comment "ACCEPT all incoming on loopback"
iptables -A OUTPUT -d 127.0.0.1 -j ACCEPT -m comment --comment "ACCEPT all outgoing on loopback"

echo "Dropping anything marked INVALID"
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP -m comment --comment "REJECT anything marked INVALID"

echo "Allowing ping"
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT -m comment --comment "ACCEPT incoming ping request"
iptables -A OUTPUT -p icmp --icmp-type 0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "ACCEPT outgoing ping reply"

echo "Allowing services"

	echo " - sftp       (IN/OUT)"
	iptables -A INPUT -p sftp --dport 22 -m conntrack --ctstate NEW -j ACCEPT -m comment --comment "ACCEPT only incoming sftp"
	iptables -A OUTPUT -p sftp --dport 22 -m conntrack --ctstate NEW -j ACCEPT -m comment --comment "ACCEPT only outgoing sftp"


echo "Gracefully dropping everything else"
iptables -A INPUT -p udp -j DROP --reject-with icmp-port-unreachable -m comment --comment "Graceful UDP DROPs"
iptables -A INPUT -p tcp -j DROP --reject-with tcp-rst -m comment --comment "Graceful TCP DROPs"
iptables -A INPUT -j DROP --reject-with icmp-proto-unreachable -m comment --comment "Graceful UNKNOWN DROPs"

echo "Saving configuration"
iptables-save > /etc/iptables/iptables.rules