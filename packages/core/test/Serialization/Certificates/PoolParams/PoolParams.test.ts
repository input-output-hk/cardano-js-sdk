/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano/index.js';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { PoolParams } from '../../../../src/Serialization/index.js';

const poolParameters: Cardano.PoolParameters = {
  cost: 1000n,
  id: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
  margin: { denominator: 5, numerator: 1 },
  metadataJson: {
    hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
    url: 'https://example.com'
  },
  owners: [Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')],
  pledge: 10_000n,
  relays: [
    { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
    {
      __typename: 'RelayByAddress',
      ipv4: '127.0.0.1',
      port: 6000
    },
    { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
  ],
  rewardAccount: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
  vrf: Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
};

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '89581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef9258208dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db01927101903e8d81e820105581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f81581ccb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f8383011913886b6578616d706c652e636f6d8400191770447f000001f682026b6578616d706c652e636f6d827368747470733a2f2f6578616d706c652e636f6d58200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
);

// Test data used in the following tests was generated with the cardano-serialization-lib
describe('PoolParams', () => {
  it('can decode PoolParams from CBOR', () => {
    const params = PoolParams.fromCbor(cbor);

    expect(params.operator()).toEqual(
      Cardano.PoolId.toKeyHash(Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'))
    );
    expect(params.vrfKeyHash()).toEqual(
      Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
    );
    expect(params.pledge()).toEqual(10_000n);
    expect(params.cost()).toEqual(1000n);
    expect(params.margin().toCore()).toEqual({ denominator: 5, numerator: 1 });
    expect(params.rewardAccount().toAddress().toBech32()).toEqual(
      Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')
    );
    expect(
      params
        .poolOwners()
        .toCore()
        .map((keyHash) => Cardano.createRewardAccount(keyHash, params.rewardAccount().toAddress().getNetworkId()))
    ).toEqual([Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')]);
    expect(params.relays().map((relay) => relay.toCore())).toEqual([
      { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
      {
        __typename: 'RelayByAddress',
        ipv4: '127.0.0.1',
        port: 6000
      },
      { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
    ]);
    expect(params.poolMetadata()?.toCore()).toEqual({
      hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
      url: 'https://example.com'
    });
  });

  it('can decode PoolParams from Core', () => {
    const params = PoolParams.fromCore(poolParameters);

    expect(params.operator()).toEqual(
      Cardano.PoolId.toKeyHash(Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'))
    );
    expect(params.vrfKeyHash()).toEqual(
      Cardano.VrfVkHex('8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0')
    );
    expect(params.pledge()).toEqual(10_000n);
    expect(params.cost()).toEqual(1000n);
    expect(params.margin().toCore()).toEqual({ denominator: 5, numerator: 1 });
    expect(params.rewardAccount().toAddress().toBech32()).toEqual(
      Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')
    );
    expect(
      params
        .poolOwners()
        .toCore()
        .map((keyHash) => Cardano.createRewardAccount(keyHash, params.rewardAccount().toAddress().getNetworkId()))
    ).toEqual([Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')]);
    expect(params.relays().map((relay) => relay.toCore())).toEqual([
      { __typename: 'RelayByName', hostname: 'example.com', port: 5000 },
      {
        __typename: 'RelayByAddress',
        ipv4: '127.0.0.1',
        port: 6000
      },
      { __typename: 'RelayByNameMultihost', dnsName: 'example.com' }
    ]);
    expect(params.poolMetadata()?.toCore()).toEqual({
      hash: Crypto.Hash32ByteBase16('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'),
      url: 'https://example.com'
    });
  });

  it('can encode PoolParams to CBOR', () => {
    const params = PoolParams.fromCore(poolParameters);

    expect(params.toCbor()).toEqual(cbor);
  });

  it('can encode PoolParams to Core', () => {
    const params = PoolParams.fromCbor(cbor);

    expect(params.toCore()).toEqual(poolParameters);
  });
});
