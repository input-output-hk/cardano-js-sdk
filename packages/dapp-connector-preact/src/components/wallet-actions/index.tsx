import { Store, connectorStore } from '../../state/store';
import { sendCoins, sendSeveralAssets, singleDelegation, singleUndelegation } from '../../features';
import { useEffect, useState } from 'preact/hooks';

import './wallet-actions.css';

export const WalletActions = () => {
  const [storeState, setStoreState] = useState<Store>(connectorStore.initialState);

  useEffect(() => {
    const subscription = connectorStore.subscribe(setStoreState);
    connectorStore.init();

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  if (!storeState.wallet) {
    return null;
  }

  const handleSendCoins = async () => {
    if (!storeState.wallet) {
      return null;
    }

    const { hash, txId } = await sendCoins({ connectedWallet: storeState.wallet });
    connectorStore.log({
      hash,
      title: 'Send coins',
      txId
    });
  };

  const handleSendSeveralAssets = async () => {
    if (!storeState.wallet) {
      return null;
    }

    const { hash, txId } = await sendSeveralAssets({ connectedWallet: storeState.wallet });
    connectorStore.log({
      hash,
      title: 'Send several assets',
      txId
    });
  };

  const handleSingleDelegation = async () => {
    if (!storeState.wallet) {
      return null;
    }

    const { hash, txId } = await singleDelegation({ connectedWallet: storeState.wallet });
    connectorStore.log({
      hash,
      title: 'Single delegation',
      txId
    });
  };

  const handleSingleUndelegation = async () => {
    if (!storeState.wallet) {
      return null;
    }

    const { hash, txId } = await singleUndelegation({ connectedWallet: storeState.wallet });
    connectorStore.log({
      hash,
      title: 'Single undelegation',
      txId
    });
  };

  return (
    <div class="actions-container">
      <h3>Wallet actions</h3>
      <button class="wallet-button" onClick={() => handleSendCoins()}>
        Send coins
      </button>
      <button class="wallet-button" onClick={() => handleSendSeveralAssets()}>
        Send several assets
      </button>
      <button class="wallet-button" onClick={() => handleSingleDelegation()}>
        Single delegation
      </button>
      <button class="wallet-button" onClick={() => handleSingleUndelegation()}>
        Single undelegation
      </button>
    </div>
  );
};
