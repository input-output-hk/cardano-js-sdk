#!/bin/bash

# Trezor Bridge Installation Script
# This script helps install Trezor Bridge on different platforms

set -e

echo "🔧 Installing Trezor Bridge..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "📱 macOS detected"
    
    if command -v brew > /dev/null 2>&1; then
        echo "Installing via Homebrew..."
        brew install trezor-suite
    else
        echo "❌ Homebrew not found. Please install Trezor Suite manually:"
        echo "   1. Download from https://suite.trezor.io/"
        echo "   2. Install the application"
        echo "   3. Trezor Bridge will be installed automatically"
        echo ""
        echo "Alternatively, install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo "🐧 Linux detected"
    
    # Check if we're on Ubuntu/Debian
    if command -v dpkg > /dev/null 2>&1; then
        echo "Installing .deb package..."
        wget -O /tmp/trezor-bridge.deb https://wallet.trezor.io/data/bridge/2.0.31/trezor-bridge_2.0.31_amd64.deb
        sudo dpkg -i /tmp/trezor-bridge.deb || sudo apt-get install -f
        rm /tmp/trezor-bridge.deb
    else
        echo "❌ Unsupported Linux distribution. Please install Trezor Bridge manually:"
        echo "   https://suite.trezor.io/trezor-bridge"
    fi
    
else
    echo "❌ Unsupported operating system: $OSTYPE"
    echo "Please install Trezor Bridge manually from:"
    echo "   https://suite.trezor.io/trezor-bridge"
fi

echo ""
echo "✅ Trezor Bridge installation complete!"
echo ""
echo "🚀 Next steps:"
echo "   1. Connect your Trezor device"
echo "   2. Unlock your Trezor device"
echo "   3. Start Trezor Bridge: trezord"
echo "   4. Run tests: yarn test:hw:trezor"
