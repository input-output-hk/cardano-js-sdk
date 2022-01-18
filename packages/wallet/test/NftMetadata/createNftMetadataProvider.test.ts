import { Cardano } from '@cardano-sdk/core';
import { WalletProvider } from '@cardano-sdk/blockfrost';
import { createNftMetadataProvider } from '../../src/NftMetadata';
import { of } from 'rxjs';

jest.mock('../../src/NftMetadata/metadatumToCip25');
const { metadatumToCip25 } = jest.requireMock('../../src/NftMetadata/metadatumToCip25');

describe('NftMetadata/createNftMetadataProvider', () => {
  const metadatum = { some: 'metadatum' };
  const transactionId = 'txId';
  const asset = { history: [{ quantity: 1, transactionId }] } as unknown as Cardano.Asset;
  const assetMetadata = { cip25: 'metadata' };

  beforeAll(() => metadatumToCip25.mockReturnValue(assetMetadata));
  afterEach(() => metadatumToCip25.mockClear());

  it('queries tx and returns nft metadata', async () => {
    const walletProvider = {
      queryTransactionsByHashes: jest.fn().mockResolvedValueOnce([{ auxiliaryData: { body: { blob: metadatum } } }])
    } as unknown as WalletProvider;
    const provider = createNftMetadataProvider(walletProvider, of([]));
    expect(await provider(asset)).toBe(assetMetadata);
    expect(metadatumToCip25).toBeCalledWith(asset, metadatum);
    expect(walletProvider.queryTransactionsByHashes).toBeCalledWith([transactionId]);
  });

  it('doesnt query wallet provider if there is a local tx', async () => {
    // will throw if walletProvider.queryTransactionsByHashes is called
    const walletProvider = undefined as unknown as WalletProvider;
    const provider = createNftMetadataProvider(
      walletProvider,
      of([{ auxiliaryData: { body: { blob: metadatum } }, id: transactionId } as unknown as Cardano.TxAlonzo])
    );
    expect(await provider(asset)).toBe(assetMetadata);
    expect(metadatumToCip25).toBeCalledWith(asset, metadatum);
  });
});
