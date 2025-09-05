# Cardano JS SDK | Hardware | Trezor

Hardware wallet integration for Trezor devices in the Cardano ecosystem. This package provides secure key management and transaction signing capabilities for Trezor hardware wallets.

## Features

- 🔐 **Secure Key Management** - Private keys never leave the Trezor device
- 🔄 **Multiple Master Key Generation Schemes** - Support for ICARUS, ICARUS_TREZOR, and LEDGER master key generation algorithms
- 📝 **Transaction Signing** - Sign Cardano transactions securely on hardware
- 🏗️ **TypeScript Support** - Full type safety and IntelliSense support
- 🔌 **Trezor Connect Integration** - Built on the official Trezor Connect library

## Installation

```bash
npm install @cardano-sdk/hardware-trezor
# or
yarn add @cardano-sdk/hardware-trezor
```

## Prerequisites

- **Trezor Device** - Model T, One, or newer
- **Trezor Bridge** - Required for USB communication
- **Node.js** - Version 16.20.1 or higher

### Quick Setup

For automated setup of the Trezor testing environment:

```bash
# Set up Trezor testing environment (from wallet package)
./packages/wallet/scripts/setup-hw-testing.sh

# Or install Trezor Bridge only
./packages/wallet/scripts/install-trezor-bridge.sh
```

## Quick Start

### Basic Usage

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { Cardano, CommunicationType } from '@cardano-sdk/core';

// Create a key agent with default settings
const keyAgent = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your-app.com',
      email: 'contact@your-app.com'
    }
  }
}, dependencies);
```

### With Custom Derivation Type

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { Cardano, CommunicationType } from '@cardano-sdk/core';

// Create a key agent with specific derivation type
const keyAgent = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: {
    communicationType: CommunicationType.Node,
    derivationType: 'ICARUS', // or 'ICARUS_TREZOR', 'LEDGER'
    manifest: {
      appUrl: 'https://your-app.com',
      email: 'contact@your-app.com'
    }
  }
}, dependencies);
```

## Master Key Generation Schemes

The package supports three master key generation algorithms for compatibility with different wallet types:

### ICARUS (Baseline - Software Wallets)
- **Value**: `'ICARUS'`
- **Use Case**: Software wallets
- **Algorithm**: Standard CIP-3 (BIP-39 → Ed25519-BIP32)
- **Technical Flow**: `Mnemonic → entropy → BIP-39 seed (using PBKDF2-HMAC-SHA512, with optional passphrase) → ed25519-bip32 master key (CIP-3 spec)`

### ICARUS_TREZOR (Trezor Hardware Compatibility)
- **Value**: `'ICARUS_TREZOR'`
- **Use Case**: Trezor hardware wallets
- **Algorithm**: Trezor's variant of CIP-3 with different PRF for 24-word mnemonics
- **Technical Details**: Trezor historically diverged in how it turned the BIP-39 seed into the root master key when dealing with 24-word mnemonics. Instead of doing a direct Icarus (CIP-3) root generation, firmware used a slightly different PRF step when expanding the seed into the Ed25519-BIP32 master key.

### LEDGER (Ledger Hardware Wallet)
- **Value**: `'LEDGER'`
- **Use Case**: Ledger hardware wallets
- **Algorithm**: Ledger's CIP-3 implementation

## Key Difference: ICARUS vs ICARUS_TREZOR

**Behavior:**
- **12/18-word mnemonics**: `ICARUS` and `ICARUS_TREZOR` produce identical keys
- **24-word mnemonics**: `ICARUS` and `ICARUS_TREZOR` produce different keys

> **⚠️ Important**: When restoring a Trezor wallet, use `ICARUS_TREZOR` for 24-word mnemonics that originated from Trezor devices, otherwise you'll get wrong addresses.

**Why it matters:**
If you're writing code to restore a Trezor wallet, you must select the correct derivation scheme (`ICARUS_TREZOR`) if the mnemonic came from a Trezor, otherwise you'll get a completely different xpub tree and addresses won't match.

### Usage Examples

```typescript
// Software wallet compatibility
const softwareWallet = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: { derivationType: 'ICARUS' }
});

// Trezor wallet (uses internal default)
const trezorWallet = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: { /* no derivationType */ }
});

// Ledger wallet migration
const ledgerWallet = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: { derivationType: 'LEDGER' }
});
```

## Configuration

### TrezorConfig Interface

```typescript
interface TrezorConfig {
  communicationType: CommunicationType;
  derivationType?: 'ICARUS' | 'ICARUS_TREZOR' | 'LEDGER'; // Master key generation scheme
  manifest: {
    appUrl: string;
    email: string;
  };
  shouldHandlePassphrase?: boolean;
}
```

### Communication Types

- **`CommunicationType.Node`** - USB communication via Trezor Bridge (recommended for Node.js)
- **`CommunicationType.Web`** - Web-based communication (for browser environments)

## API Reference

### TrezorKeyAgent

#### `createWithDevice(options, dependencies)`

Creates a new TrezorKeyAgent instance with a connected Trezor device.

**Parameters:**
- `options.chainId` - Cardano chain ID (Mainnet, Preprod, etc.)
- `options.trezorConfig` - Trezor configuration object
- `dependencies` - Required dependencies (crypto, logger, etc.)

**Returns:** `Promise<TrezorKeyAgent>`

#### `getXpub(props)`

Retrieves the extended public key from the Trezor device.

**Parameters:**
- `props.purpose` - Key purpose (Payment, Stake, etc.)
- `props.accountIndex` - Account index
- `props.derivationType` - Optional master key generation scheme override

**Returns:** `Promise<Bip32PublicKeyHex>`

#### `signTransaction(txBody, context)`

Signs a Cardano transaction using the Trezor device.

**Parameters:**
- `txBody` - Transaction body to sign
- `context` - Signing context (addresses, key paths, etc.)

**Returns:** `Promise<CardanoTxWitnesses>`

## Error Handling

The package provides comprehensive error handling for common scenarios:

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';

try {
  const keyAgent = await TrezorKeyAgent.createWithDevice(config, deps);
} catch (error) {
  if (error.message.includes('Trezor transport failed')) {
    // Handle device connection issues
    console.error('Please ensure your Trezor device is connected and unlocked');
  } else if (error.message.includes('Authentication failure')) {
    // Handle authentication issues
    console.error('Please check your Trezor device and try again');
  }
}
```

## Troubleshooting

### Common Issues

1. **"Trezor transport failed"**
   - Ensure Trezor Bridge is installed and running
   - Check USB connection
   - Verify device is unlocked

2. **"Authentication failure"**
   - Unlock your Trezor device
   - Close other applications using the device
   - Try reconnecting the device

3. **Wrong master key generation scheme**
   - Verify the master key generation scheme matches your wallet's origin
   - Check the MASTER_KEY_GENERATION.md for detailed guidance

### Device Setup

1. **Install Trezor Bridge**
   ```bash
   # Download from https://suite.trezor.io/trezor-bridge
   # Or install via package manager
   ```

2. **Connect and Unlock Device**
   - Connect your Trezor device via USB
   - Unlock the device using your PIN
   - Ensure no other applications are using the device

## Examples

### Complete Wallet Integration

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { createPersonalWallet } from '@cardano-sdk/wallet';
import { Cardano, CommunicationType } from '@cardano-sdk/core';

async function createTrezorWallet() {
  // Create key agent
  const keyAgent = await TrezorKeyAgent.createWithDevice({
    chainId: Cardano.ChainIds.Mainnet,
    trezorConfig: {
      communicationType: CommunicationType.Node,
      derivationType: 'ICARUS_TREZOR', // or omit to use Trezor's internal default
      manifest: {
        appUrl: 'https://my-cardano-app.com',
        email: 'support@my-cardano-app.com'
      }
    }
  }, dependencies);

  // Create wallet
  const wallet = createPersonalWallet(
    { name: 'My Trezor Wallet' },
    {
      keyAgent,
      // ... other providers
    }
  );

  return wallet;
}
```

## Development

### Running Tests

```bash
# Run all tests
yarn test

# Run with coverage
yarn test --coverage

# Run specific test file
yarn test TrezorKeyAgent.test.ts
```

### Building

```bash
# Build the package
yarn build

# Build and watch for changes
yarn build --watch
```

## Implementation Details

### Default Behavior
When no `derivationType` is specified in the `TrezorConfig`, the SDK passes no derivation type to Trezor, allowing Trezor to use its own internal default:

```typescript
const trezorConfig: TrezorConfig = {
  communicationType: CommunicationType.Node,
  manifest: {
    appUrl: 'https://your.application.com',
    email: 'email@developer.com'
  }
  // No derivationType specified - Trezor uses its internal default
};

## Troubleshooting

### Common Issues

1. **Wrong addresses when restoring Trezor wallet**: Use `ICARUS_TREZOR` for 24-word mnemonics that originated from Trezor devices
2. **Same keys for different schemes**: This is expected for 12/18-word seeds with `ICARUS` and `ICARUS_TREZOR`
3. **Test failures**: Ensure tests account for both 12/18 and 24-word seed scenarios

### Debugging

To determine which scenario you're dealing with:

```typescript
const defaultXPub = defaultKeyAgent.extendedAccountPublicKey;
const icarusXPub = icarusKeyAgent.extendedAccountPublicKey;

if (defaultXPub === icarusXPub) {
  console.log('12/18 word seed detected - ICARUS and ICARUS_TREZOR master key generation schemes are identical');
} else {
  console.log('24 word seed detected - ICARUS and ICARUS_TREZOR master key generation schemes are different');
}
```

## Related Documentation

- [Cardano JS SDK Documentation](https://github.com/input-output-hk/cardano-js-sdk)
- [Trezor Connect Documentation](https://docs.trezor.io/trezor-connect/)
- [CIP-1852: HD Wallets for Cardano](https://cips.cardano.org/cips/cip1852/)
- [CIP-3: Wallet Key Generation](https://cips.cardano.org/cips/cip3/)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

## Support

For issues and questions:
- [GitHub Issues](https://github.com/input-output-hk/cardano-js-sdk/issues)
- [Cardano Community](https://cardano.org/community)