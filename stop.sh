#!/bin/bash
# usbncmbridge - stop.sh
mkdir -p $TMPDIR/usbncmbridge

# Checking if bridge was written to temp folder
if [[ ! " $* " == *" -y"* ]]; then
  if [[ ! -f $TMPDIR/usbncmbridge/bridge ]]; then
    echo "usbncmbridge"
    echo "stop.sh can only be ran while the network bridge is active."
    echo "Add the -y parameter to this command if start.sh failed and you want to restore your firewall configuration."
  fi
fi

# The script
ipfresult=$(sysctl -w net.inet.ip.forwarding)
ipfvalue=$(echo $ipfresult | grep -oE '[01]$')
fwstatus=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
if [[ $fwstatus != *"enabled"* ]]; then
  if [ -f $TMPDIR/usbncmbridge/firewall_modified ]; then
    # Restore firewall config
    echo "We've detected that usbncmbridge previously disabled your system's firewall. The firewall will now be re-enabled."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    rm $TMPDIR/usbncmbridge/firewall_modified
  fi
fi

if [ "$ipfvalue" == "1" ]; then
  if [ -f $TMPDIR/usbncmbridge/ip_forwarding_modified ]; then
    # Restore IP forwarding config
    sudo sysctl -w net.inet.ip.forwarding=0
    rm $TMPDIR/usbncmbridge/ip_forwarding_modified
  fi
fi

if [ -f $TMPDIR/usbncmbridge/bridge ]; then
  # Destroy network bridge
  bridge=$(cat $TMPDIR/usbncmbridge/bridge)
  sudo ifconfig $bridge destroy
  rm $TMPDIR/usbncmbridge/bridge
fi
