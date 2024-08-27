# usbncmbridge
usbncmbridge is a simple macOS command-line utility to bridge USB-NCM signals from a device not natively supported on Windows, such as an Apple Vision Pro, to Windows so that it can be detected and used.
## Installation
Clone this repository and `chmod +x` the start.sh and stop.sh scripts to make them executable. Please note that usbncmbridge currently only supports macOS and will fail to start on Linux.
## Usage
Run `ifconfig` to find the source and destination network interfaces, then run `./start.sh <source> <destination>` with that source and destination. To stop the bridge, run `./stop.sh`.
> [!WARNING]
> usbncmbridge will temporarily disable your system firewall and enable IP forwarding when you run `start.sh`, as this is required for the system to bridge connections properly. These changes will be reverted when `stop.sh` is ran.
