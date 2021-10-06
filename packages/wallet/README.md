# Cardano JS SDK | Wallet

# Examples

## Delegation

```typescript
import { createSingleAddressWallet, KeyManagement, Delegation, SingleAddressWalletDependencies } from '@cardano-sdk/wallet';

async () => {
  const keyManager = KeyManagement.createInMemoryKeyManager({ ... });
  const wallet = await createSingleAddressWallet({ name: 'some-wallet' }, { keyManager, ... });

  const certs = new Delegation.CertificateFactory(keyManager);
  const { body, hash } = await wallet.initializeTx({ certificates: [certs.stakeKeyRegistration()], ... });
  const tx = await wallet.signTx(body, hash);

  await wallet.submitTx(tx);
}
```
