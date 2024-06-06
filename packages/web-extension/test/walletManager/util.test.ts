import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization } from '@cardano-sdk/core';
import type { AsyncKeyAgent } from '@cardano-sdk/key-management';

import { HexBlob } from '@cardano-sdk/util';
import { getWalletId } from '../../src/index.js';

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

  it('can create unique id for key agents', async () => {
    const id1 = await getWalletId(mockKeyAgent);
    pubKey = Crypto.Bip32PublicKeyHex(
      // eslint-disable-next-line max-len
      '4e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
    );
    const id2 = await getWalletId(mockKeyAgent);
    expect(id1).not.toEqual(id2);
  });

  it('can create unique id for public keys', async () => {
    const id1 = await getWalletId(
      Crypto.Bip32PublicKeyHex(
        // eslint-disable-next-line max-len
        '3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
      )
    );
    const id2 = await getWalletId(
      Crypto.Bip32PublicKeyHex(
        // eslint-disable-next-line max-len
        '4e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d3e33018e8293d319ef5b3ac72366dd28006bd315b715f7e7cfcbd3004129b80d'
      )
    );
    expect(id1).not.toEqual(id2);
  });

  it('can create unique id for scripts', async () => {
    const script = Serialization.Script.fromCbor(
      HexBlob(
        '82008202828200581cb275b08c999097247f7c17e77007c7010cd19f20cc086ad99d3985388201838205190bb88200581c966e394a544f242081e41d1965137b1bb412ac230d40ed5407821c378204190fa0'
      )
    ).toCore();

    const nativeScript: Cardano.Script = {
      __type: Cardano.ScriptType.Native,
      keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398538'),
      kind: Cardano.NativeScriptKind.RequireSignature
    };

    const id1 = await getWalletId(script);
    const id2 = await getWalletId(nativeScript);

    expect(id1).not.toEqual(id2);
  });
});
