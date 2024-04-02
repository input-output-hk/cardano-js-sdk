import { Store, connectorStore } from '../../state/store';
import { useEffect, useState } from 'preact/hooks';

import './logs.css';

export const Logs = () => {
  const [storeState, setStoreState] = useState<Store>(connectorStore.initialState);

  useEffect(() => {
    const subscription = connectorStore.subscribe(setStoreState);
    connectorStore.init();

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  if (!storeState.wallet || !storeState.addresses || !storeState.balance) {
    return null;
  }

  const getAddresses = () => storeState.addresses?.map((a) => <p>{a.address}</p>);

  return (
    <div class="logs-container">
      <h3>Logs</h3>
      <div>
        <h4>Balance: </h4> <p>{storeState?.balance?.coins}</p>
        <h4>Addresses: </h4> {getAddresses()}
      </div>
      <div>
        {storeState.log.map((entry) => (
          <>
            <h4>{entry.title}</h4>
            <p>
              <h5>hash:</h5>
              {entry.hash}
            </p>
            <p>
              <h5>tx ID:</h5> {entry.txId}
            </p>
          </>
        ))}
      </div>
    </div>
  );
};
