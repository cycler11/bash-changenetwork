usage() {
    echo "Usage: $0 <interface> <new_ip> <netmask> <gateway>"
    echo "Example: $0 eth0 192.168.1.100 255.255.255.0 192.168.1.1"
}

backup_config() {
    cp /etc/network/interfaces /etc/network/interfaces.backup
}


restore_config() {
    cp /etc/network/interfaces.backup /etc/network/interfaces
}
modify_config() {
    interface=$1
    new_ip=$2
    netmask=$3
    gateway=$4

    backup_config

    sed -i "/iface $interface inet static/,+3 s/^.*$/    address $new_ip\n    netmask $netmask\n    gateway $gateway/" /etc/network/interfaces

    /etc/init.d/networking restart
}

display_network_info() {
    echo "Current network configuration:"
    ip -4 addr show $1 | grep inet
    ip route show
}

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

if [ "$#" -ne 4 ]; then
    usage
    exit 1
fi

interface=$1
new_ip=$2
netmask=$3
gateway=$4

modify_config $interface $new_ip $netmask $gateway

display_network_info $interface

echo "Network configuration has been successfully updated."
