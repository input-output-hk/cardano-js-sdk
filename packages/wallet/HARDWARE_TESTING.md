# Hardware Testing Environment

This document explains how to set up and run hardware tests for Trezor and Ledger devices.

## Prerequisites

- **Trezor Device**: Model T, One, or newer
- **Trezor Bridge**: Required for USB communication
- **Node.js**: Version 16.20.1 or higher

## Quick Start

### Option 1: Automated Setup (Recommended)

Use the provided setup script to automatically install dependencies and configure your environment:

```bash
# Run the automated setup script
./scripts/setup-hw-testing.sh
```

This script will:
- Install Trezor Bridge automatically
- Set up udev rules (Linux only)
- Create necessary directories
- Make all scripts executable

### Option 2: Manual Setup

#### 1. Install Trezor Bridge

**Using the installation script:**
```bash
./scripts/install-trezor-bridge.sh
```

**Or manually:**

**macOS:**
```bash
brew install trezor-suite
```

**Linux:**
```bash
# Download from https://suite.trezor.io/trezor-bridge
# Or use your package manager
```

**Windows:**
- Download from [Trezor Suite](https://suite.trezor.io/trezor-bridge)

### 2. Start Trezor Bridge

```bash
# Start Trezor Bridge
trezord
```

### 3. Run Tests

```bash
# Run tests with your physical Trezor device
yarn test:hw:trezor
```

## Available Test Commands

| Command | Description |
|---------|-------------|
| `yarn test:hw:trezor` | Run Trezor hardware tests |
| `yarn test:hw:ledger` | Run Ledger hardware tests |

## Test Structure

Hardware tests are located in:
- `test/hardware/trezor/` - Trezor-specific tests
- `test/hardware/ledger/` - Ledger-specific tests

## Troubleshooting

### Common Issues

#### "Trezor transport failed"
- Ensure Trezor Bridge is running: `trezord`
- Check device connection
- Verify device is unlocked

#### "No Trezor device connected/unlocked"
- Connect your Trezor device via USB
- Unlock the device using your PIN
- Ensure no other applications are using the device

#### "Authentication failure"
- Unlock your Trezor device
- Close other applications using the device
- Try reconnecting the device

## Security Notes

- Never use real hardware devices in CI/CD
- Physical devices should only be used in secure development environments
- Always verify device authenticity before use

## Development

### Adding New Tests

1. Create test files in `test/hardware/trezor/` or `test/hardware/ledger/`
2. Use the existing test patterns
3. Ensure tests work with physical devices

### Test Patterns

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';

describe('TrezorKeyAgent', () => {
  it('should work with hardware device', async () => {
    const keyAgent = await TrezorKeyAgent.createWithDevice({
      chainId: Cardano.ChainIds.Preprod,
      trezorConfig: {
        communicationType: CommunicationType.Node,
        manifest: {
          appUrl: 'https://your-app.com',
          email: 'contact@your-app.com'
        }
      }
    }, dependencies);
    
    // Test your functionality
  });
});
```
