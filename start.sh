#!/bin/bash
# usbncmbridge - start.sh

# Defining functions
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

# Check if $1 or $2 is empty
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usbncmbridge"
    echo "Usage: $0 <source> <destination>"
    echo "To find the source and destination, run the ifconfig command."
    exit 1
fi

# The script
mkdir -p $TMPDIR/usbncmbridge
ipfresult=$(sysctl -w net.inet.ip.forwarding)
ipfvalue=$(echo $ipfresult | grep -oE '[01]$')
fwstatus=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
if [[ $fwstatus == *"enabled"* ]]; then
  # The firewall must be temporarily disabled in order for usbncmbridge to function.
  # If you are not comfortable will this, do not run this script.
  confirm "The system firewall must be disabled in order for usbncmbridge to function. Would you like to disable the system firewall now? [y/N]" && sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off && touch $TMPDIR/usbncmbridge/firewall_modified
fi

if [ "$ipfvalue" != "1" ]; then
  # IP forwarding must be temporarily enabled in order for usbncmbridge to function.
  sudo sysctl -w net.inet.ip.forwarding=1 && touch $TMPDIR/usbncmbridge/ip_forwarding_modified
fi

bridge=$(sudo ifconfig bridge create)
echo $bridge > $TMPDIR/usbncmbridge/bridge
sudo ifconfig $bridge addm $2 addm $1 up
echo "Done! $bridge"
