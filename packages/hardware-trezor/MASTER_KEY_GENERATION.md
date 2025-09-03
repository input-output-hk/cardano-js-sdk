# Trezor Master Key Generation Types

This package now supports multiple master key generation algorithms for Trezor hardware wallets, allowing compatibility with different wallet implementations and enabling seamless integration with various existing wallet types.

## Supported Master Key Generation Types

### 1. ICARUS
- Standard CIP-3 wallet compatibility mode

### 2. ICARUS_TREZOR
- CIP-3 variant with 24-word mnemonic compatibility
- This is Trezor's internal default (SDK passes no `derivationType`)

### 3. LEDGER
- Ledger hardware wallet compatibility mode
- Use this if your wallet was originally created on a Ledger device
- Enables access to Ledger-generated accounts on Trezor hardware

## Key Concept

All types use the same derivation path but different master key generation algorithms from the mnemonic. The `derivationType` tells Trezor which algorithm to use.

## Usage

### Importing Types and Constants

All types and constants are fully exportable from their respective packages:

```typescript
// Core constants
import {
  HD_WALLET_CIP_ID,
  Cardano
} from '@cardano-sdk/core';

// Key management types
import {
  TrezorConfig,
  KeyPurpose,
  MasterKeyGeneration
} from '@cardano-sdk/key-management';

// Hardware Trezor implementation
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
```



### Basic Configuration

```typescript
import { TrezorConfig, MasterKeyGeneration } from '@cardano-sdk/key-management';

const trezorConfig: TrezorConfig = {
  communicationType: 'web',
  manifest: {
    email: 'user@example.com',
    appUrl: 'https://myapp.com'
  },
  // Use CIP-3 master key generation
  derivationType: 'ICARUS'
};
```



### Creating a Trezor Key Agent

```typescript
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { Cardano } from '@cardano-sdk/core';
import { createBip32Ed25519 } from '@cardano-sdk/crypto';

const dependencies = {
  logger: console, // or your preferred logger
  bip32Ed25519: await createBip32Ed25519()
};

const keyAgent = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  accountIndex: 0,
  trezorConfig: {
    communicationType: 'web',
    manifest: {
      email: 'user@example.com',
      appUrl: 'https://myapp.com'
    },
    derivationType: 'ICARUS'
  }
}, dependencies);
```



## Discovery & UX Guidelines

### Automatic Discovery Pattern

When pairing a Trezor device, follow this discovery pattern to find existing accounts:

1. **Try ICARUS first** - Most common for software wallets
2. **Try ICARUS_TREZOR** - If balance not found and user has 24-word mnemonic
3. **Try LEDGER** - If user confirms wallet was originally created on Ledger device

This is why many wallet UIs show a "Derivation type override" dropdown - to help users discover their existing accounts.

### Manual Selection During Onboarding

For applications that prefer explicit user control, consider exposing derivation type selection during the onboarding process:

```typescript
// Example onboarding flow
const derivationTypeOptions = [
  { value: 'ICARUS', label: 'Software Wallet', description: 'Most common for wallets created with software applications' },
  { value: 'ICARUS_TREZOR', label: 'Trezor Default', description: 'Trezor\'s internal default (24-word mnemonic compatible)' },
  { value: 'LEDGER', label: 'Ledger Hardware Wallet', description: 'For wallets originally created on Ledger devices' }
];

// Let user select during onboarding
const selectedDerivationType = await showDerivationTypeSelection(derivationTypeOptions);

const keyAgent = await TrezorKeyAgent.createWithDevice({
  chainId: Cardano.ChainIds.Mainnet,
  trezorConfig: {
    communicationType: 'web',
    manifest: { email: 'user@example.com', appUrl: 'https://myapp.com' },
    derivationType: selectedDerivationType
  }
}, dependencies);
```

**Benefits of Manual Selection:**
- **User Control**: Users explicitly choose their derivation type
- **Multi-Wallet Support**: Users can create multiple wallets with different derivation types
- **Transparency**: Clear understanding of which derivation type is being used
- **No Guessing**: Eliminates the need for automatic discovery patterns

**When to Use Manual Selection:**
- Applications that prioritize user control and transparency
- Multi-wallet applications where users might have accounts with different derivation types
- Enterprise applications where explicit configuration is preferred
- When users have used multiple wallet types and need to access different accounts

## Implementation Details

When a non-default derivation type is specified, the SDK sets the appropriate `derivationType` in the `cardanoSignTransaction` call. For the default type, no `derivationType` is sent to Trezor.

## Backward Compatibility

Existing wallets without a `derivationType` configuration will continue to work as before. No changes are required for existing users.



## References

- **[CIP-1852](https://cips.cardano.org/cip/CIP-1852)**: HD paths and role meanings
- **[CIP-3](https://cips.cardano.org/cip/CIP-3)**: Master key generation and 24-word compatibility note
- **[Trezor Forum](https://forum.trezor.io/t/cardano-ada-transaction-signing-error/10466)**: Community discussion on derivation types
- **[Cardano Stack Exchange](https://cardano.stackexchange.com/questions/5977/how-does-ledger-generate-the-public-keys)**: Ledger key generation details
- **[Cardano Foundation](https://cardano-foundation.github.io/cardano-wallet/concepts/master-key-generation)**: Master key generation background
