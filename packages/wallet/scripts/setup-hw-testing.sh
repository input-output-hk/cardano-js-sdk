#!/bin/bash

# Hardware Testing Environment Setup Script
# This script sets up the development environment for hardware wallet testing

set -e

echo "🔧 Setting up hardware testing environment..."

# Create necessary directories
mkdir -p ./test/hardware/logs

# Make scripts executable
chmod +x ./scripts/setup-hw-testing.sh

echo "📦 Installing system dependencies..."

# Install udev rules for Trezor devices (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing udev rules for Trezor devices..."
    sudo tee /etc/udev/rules.d/51-trezor.rules > /dev/null <<EOF
# Trezor Model T
SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c0", MODE="0666", GROUP="plugdev"
# Trezor Model One
SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="53c1", MODE="0666", GROUP="plugdev"
EOF
    sudo udevadm control --reload-rules
    sudo udevadm trigger
fi

# Install Trezor Bridge (if not already installed)
if ! command -v trezord > /dev/null 2>&1; then
    echo "Installing Trezor Bridge..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew > /dev/null 2>&1; then
            brew install trezor-suite
        else
            echo "Please install Trezor Suite from https://suite.trezor.io/"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        wget -O /tmp/trezor-bridge.deb https://wallet.trezor.io/data/bridge/2.0.31/trezor-bridge_2.0.31_amd64.deb
        sudo dpkg -i /tmp/trezor-bridge.deb || sudo apt-get install -f
        rm /tmp/trezor-bridge.deb
    else
        echo "Please install Trezor Bridge manually from https://suite.trezor.io/trezor-bridge"
    fi
fi

echo "✅ Hardware testing environment setup complete!"
echo ""
echo "🚀 To start hardware testing:"
echo "  yarn test:hw:trezor           # Run tests (requires Trezor Bridge running)"
echo ""
echo "📋 Available commands:"
echo "  trezord                       # Start Trezor Bridge"
echo "  yarn test:hw:trezor          # Run Trezor hardware tests"
echo ""
echo "📝 Prerequisites:"
echo "  - Trezor device connected and unlocked"
echo "  - Trezor Bridge running (trezord)"
