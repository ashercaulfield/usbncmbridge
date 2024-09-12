#!/bin/bash
# usbncmbridge - start.sh (Linux version)
mkdir -p /tmp/usbncmbridge

# Defining functions
confirm() {
    read -r -t 30 -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

setup_firewall() {
    echo "Setting up firewall..."
    sudo iptables -F
    sudo iptables -t nat -F
    sudo iptables -t nat -A POSTROUTING -o $2 -j MASQUERADE
    sudo iptables -A FORWARD -i $2 -o $1 -m state --state RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i $1 -o $2 -j ACCEPT
    echo "Firewall setup complete."
    touch /tmp/usbncmbridge/firewall_modified
}

# Check if $1 or $2 is empty
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usbncmbridge"
    echo "Usage: $0 <source> <destination> [Y]"
    echo "To find the source and destination, run the ip link command."
    echo "Add Y at the end to automatically set up the firewall."
    exit 1
fi

# Make sure bridge hasn't already started
if [ -f /tmp/usbncmbridge/bridge ]; then
    echo "usbncmbridge"
    echo "start.sh can only be ran while the network bridge is stopped."
    echo "To stop the network bridge, run stop.sh."
    exit 1
fi

# The script
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
    # IP forwarding must be temporarily enabled
    if ! confirm "IP forwarding must be enabled for usbncmbridge to function. Would you like to enable IP forwarding now? [y/N]"; then
        exit 1
    fi
    
    echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
    touch /tmp/usbncmbridge/ip_forwarding_modified
fi

# Create bridge
bridge_name="usbncm0"
sudo ip link add name $bridge_name type bridge
echo $bridge_name > /tmp/usbncmbridge/bridge

# Add interfaces to bridge
sudo ip link set dev $1 master $bridge_name
sudo ip link set dev $2 master $bridge_name

# Bring up the bridge and interfaces
sudo ip link set dev $bridge_name up
sudo ip link set dev $1 up
sudo ip link set dev $2 up

echo "Bridge $bridge_name created and configured."

# Firewall setup
if [[ "$3" == "Y" ]] || confirm "Would you like to set up the firewall? [y/N]"; then
    setup_firewall $1 $2
fi

echo "usbncmbridge setup complete!"
