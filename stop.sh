#!/bin/bash
# usbncmbridge - stop.sh (Linux version)
mkdir -p /tmp/usbncmbridge

# Checking if bridge was written to temp folder
if [[ ! " $* " == *" -y"* ]]; then
    if [[ ! -f /tmp/usbncmbridge/bridge ]]; then
        echo "usbncmbridge"
        echo "stop.sh can only be ran while the network bridge is active."
        echo "Add the -y parameter to this command if start.sh failed and you want to restore your IP forwarding and firewall configuration."
        exit 1
    fi
fi

# The script
if [ -f /tmp/usbncmbridge/ip_forwarding_modified ]; then
    # Restore IP forwarding config
    echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward
    rm /tmp/usbncmbridge/ip_forwarding_modified
    echo "IP forwarding has been disabled."
fi

if [ -f /tmp/usbncmbridge/firewall_modified ]; then
    # Reset firewall
    sudo iptables -F
    sudo iptables -t nat -F
    rm /tmp/usbncmbridge/firewall_modified
    echo "Firewall rules have been reset."
fi

if [ -f /tmp/usbncmbridge/bridge ]; then
    # Destroy network bridge
    bridge=$(cat /tmp/usbncmbridge/bridge)
    sudo ip link set dev $bridge down
    sudo ip link delete $bridge type bridge
    rm /tmp/usbncmbridge/bridge
    echo "Bridge $bridge destroyed"
fi

echo "usbncmbridge stopped successfully."
