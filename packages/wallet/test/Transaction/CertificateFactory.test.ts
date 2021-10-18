import { testKeyManager } from '../mocks';
import { CertificateFactory } from '../../src/Transaction';
import { KeyManager } from '../../src/KeyManagement';

describe('Transaction.CertificateFactory', () => {
  let stakeKey: string;
  let keyManager: KeyManager;
  let certs: CertificateFactory;
  const delegatee = 'pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt';

  beforeAll(async () => {
    keyManager = testKeyManager();
    stakeKey = keyManager.stakeKey.hash().to_bech32('ed25519_pk');
    certs = new CertificateFactory(keyManager);
  });

  it('stakeKeyRegistration', () =>
    expect(
      certs.stakeKeyRegistration().as_stake_registration()?.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')
    ).toBe(stakeKey));

  it('stakeKeyDeregistration', () =>
    expect(
      certs.stakeKeyDeregistration().as_stake_deregistration()?.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')
    ).toBe(stakeKey));

  it('stakeDelegation', () => {
    const delegation = certs.stakeDelegation(delegatee).as_stake_delegation()!;
    expect(delegation.stake_credential().to_keyhash()?.to_bech32('ed25519_pk')).toBe(stakeKey);
    expect(delegation.pool_keyhash().to_bech32('pool')).toBe(delegatee);
  });

  it('poolRegistration', () => {
    const owner = keyManager.publicKey.hash().to_bech32('ed25519_pk');
    const vrfKeyHash = 'vrf_vk13hg4gg5fg67399nuz2ldk89kqw9h379cfgtkpvd83ra89f908kcqv2cw3j';
    const rewardAddress = 'addr1uxa5pudxg77g3sdaddecmw8tvc6hmynywn49lltt4fmvn7cmpqcax';
    const poolMetadata = {
      hash: 'pool1ntpzzu5g6xhqkns4csd435lqtgfjqm7e4wquk9v58eqhf0esey9st6vf29',
      url: 'https://example.com'
    };
    const params = certs
      .poolRegistration({
        cost: 1000n,
        pledge: 10_000n,
        margin: { denominator: 5, numerator: 1 },
        owners: [owner],
        poolKeyHash: stakeKey,
        relays: [
          { relayType: 'singlehost-name', hostname: 'example.com', port: 5000 },
          {
            relayType: 'singlehost-addr',
            port: 6000,
            ipv4: '127.0.0.1'
          },
          { relayType: 'multihost-name', dnsName: 'example.com' }
        ],
        vrfKeyHash,
        rewardAddress,
        poolMetadata
      })
      .as_pool_registration()!
      .pool_params();
    expect(params.cost().to_str()).toBe('1000');
    expect(params.pledge().to_str()).toBe('10000');
    const margin = params.margin();
    expect(margin.numerator().to_str()).toBe('1');
    expect(margin.denominator().to_str()).toBe('5');
    const owners = params.pool_owners();
    expect(owners.len()).toBe(1);
    expect(owners.get(0).to_bech32('ed25519_pk')).toBe(owner);
    expect(params.operator().to_bech32('ed25519_pk')).toBe(stakeKey);
    const relays = params.relays();
    expect(relays.len()).toBe(3);
    expect(params.vrf_keyhash().to_bech32('vrf_vk')).toBe(vrfKeyHash);
    expect(params.reward_account().to_address().to_bech32('addr')).toBe(rewardAddress);
    const metadata = params.pool_metadata()!;
    expect(metadata.url().url()).toBe(poolMetadata.url);
    expect(metadata.pool_metadata_hash().to_bech32('pool')).toBe(poolMetadata.hash);
  });

  it('poolRetirement', () => {
    const retirement = certs.poolRetirement(stakeKey, 1000).as_pool_retirement()!;
    expect(retirement.pool_keyhash().to_bech32('ed25519_pk')).toEqual(stakeKey);
    expect(retirement.epoch()).toEqual(1000);
  });
});
