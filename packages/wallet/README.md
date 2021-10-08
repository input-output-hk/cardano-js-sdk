# Cardano JS SDK | Wallet

# Examples

## Delegation

```typescript
import { loadCardanoSerializationLib } from '@cardano-sdk/core';
import { createSingleAddressWallet, KeyManagement, Transaction, SingleAddressWalletDependencies } from '@cardano-sdk/wallet';

async () => {
  const csl = await loadCardanoSerializationLib();
  const keyManager = KeyManagement.createInMemoryKeyManager({ csl, ... });
  const wallet = await createSingleAddressWallet({ name: 'some-wallet' }, { csl, keyManager, ... });

  const certs = new Transaction.CertificateFactory(keyManager);
  const { body, hash } = await wallet.initializeTx({
    certificates: [certs.stakeKeyDeregistration()],
    withdrawals: [Transaction.withdrawal(csl, keyManager, 5_000_000n)],
    ...
  });
  const tx = await wallet.signTx(body, hash);

  await wallet.submitTx(tx);
}
```
