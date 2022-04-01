import { ApiError, TxSignError, TxSignErrorCode } from '../../src/errors';
import { WalletApi } from '../../src/Wallet';
import { createListener } from '../../src/WebExtension/handleMessages';

describe('handleMessages', () => {
  const walletName = 'wallet';

  it('rejects with ApiError for non-cip30 error types', async () => {
    const signTx = jest.fn().mockRejectedValueOnce(new Error('some other error'));
    const listener = createListener(walletName, { signTx } as unknown as WalletApi);
    await expect(() => listener({ arguments: [], method: 'signTx', walletName })).rejects.toThrowError(ApiError);
  });

  it('rejects with original error if its defined by cip30', async () => {
    const signTx = jest.fn().mockRejectedValueOnce(new TxSignError(TxSignErrorCode.UserDeclined, ''));
    const listener = createListener(walletName, { signTx } as unknown as WalletApi);
    await expect(() => listener({ arguments: [], method: 'signTx', walletName })).rejects.toThrowError(TxSignError);
  });
});
