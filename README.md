# usbncmbridge

usbncmbridge is a simple Linux command-line utility to bridge USB-NCM signals from a device not natively supported on Windows, such as an Apple Vision Pro, to Windows so that it can be detected and used.

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/ashercaulfield/usbncmbridge.git
   cd usbncmbridge
   ```

2. Make the scripts executable:
   ```
   chmod +x start.sh stop.sh
   ```

## Usage

1. Find the source and destination network interfaces:
   ```
   ip link
   ```

2. Start the bridge:
   ```
   sudo ./start.sh <source> <destination> [Y]
   ```
   - Replace `<source>` and `<destination>` with the appropriate interface names.
   - Add `Y` at the end to automatically set up the firewall.

3. To stop the bridge:
   ```
   sudo ./stop.sh
   ```

## Features

- Automatically enables IP forwarding when necessary.
- Optional firewall setup to allow traffic forwarding between interfaces.
- Prompts for firewall setup if not specified in the command (30-second timeout).

> [!WARNING]
> usbncmbridge will temporarily enable IP forwarding when you run `start.sh`, as this is required for the system to bridge connections properly. If you choose to set up the firewall, it will also modify your iptables rules. These changes will be reverted when `stop.sh` is run.

## Requirements

- Linux operating system
- `sudo` privileges
- `iptables` (for firewall setup)

## Troubleshooting

If `start.sh` fails and you need to restore your IP forwarding and firewall configuration, you can run:

```
sudo ./stop.sh -y
```

This will attempt to revert changes even if the bridge wasn't successfully created.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
