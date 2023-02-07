import * as Crypto from '@cardano-sdk/crypto';
import { AsyncKeyAgent } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

import { getWalletId } from '../../src';

describe('getWalletId', () => {
  let pubKey: Crypto.Bip32PublicKeyHex;
  const chainId: Cardano.ChainId = {
    networkId: Cardano.NetworkId.Testnet,
    networkMagic: Cardano.NetworkMagics.Preview
  };
  const mockKeyAgent = {
    getChainId: async () => Promise.resolve(chainId),
    getExtendedAccountPublicKey: async () => Promise.resolve(pubKey)
  } as AsyncKeyAgent;

  beforeEach(() => {
    pubKey = Crypto.Bip32PublicKeyHex(
      // eslint-disable-next-line max-len
      '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
    );
  });

  it('creates unique id for different networkId', async () => {
    const id1 = await getWalletId(mockKeyAgent);
    chainId.networkId = Cardano.NetworkId.Mainnet;
    const id2 = await getWalletId(mockKeyAgent);
    expect(id1).not.toEqual(id2);
  });

  it('creates unique id for different networkMagic', async () => {
    const id1 = await getWalletId(mockKeyAgent);
    chainId.networkMagic = Cardano.NetworkMagics.Mainnet;
    const id2 = await getWalletId(mockKeyAgent);
    expect(id1).not.toEqual(id2);
  });

  it('create unique id for different public keys', async () => {
    const id1 = await getWalletId(mockKeyAgent);
    pubKey = Crypto.Bip32PublicKeyHex(
      // eslint-disable-next-line max-len
      '4e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
    );
    const id2 = await getWalletId(mockKeyAgent);
    expect(id1).not.toEqual(id2);
  });
});
