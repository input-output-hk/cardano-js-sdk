import { Cardano, coreToCsl } from '../../src';

describe('coreToCsl.certificate', () => {
  let stakeKey: Cardano.Address;
  const delegatee = 'pool1qqvukkkfr3ux4qylfkrky23f6trl2l6xjluv36z90ax7gfa8yxt';

  beforeAll(async () => {
    stakeKey = 'stake1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumhey8p37kz';
  });

  it('stakeKeyRegistration', () =>
    expect(
      coreToCsl.certificate
        .stakeKeyRegistration(stakeKey)
        .as_stake_registration()
        ?.stake_credential()
        .to_keyhash()
        ?.to_bech32('stake')
    ).toBe(stakeKey));

  it('stakeKeyDeregistration', () =>
    expect(
      coreToCsl.certificate
        .stakeKeyDeregistration(stakeKey)
        .as_stake_deregistration()
        ?.stake_credential()
        .to_keyhash()
        ?.to_bech32('stake')
    ).toBe(stakeKey));

  it('stakeDelegation', () => {
    const delegation = coreToCsl.certificate.stakeDelegation(stakeKey, delegatee).as_stake_delegation()!;
    expect(delegation.stake_credential().to_keyhash()?.to_bech32('stake')).toBe(stakeKey);
    expect(delegation.pool_keyhash().to_bech32('pool')).toBe(delegatee);
  });

  it('poolRegistration', () => {
    const owner = 'ed25519_pk1fapzz685dzht56689jgthxxrzcsrtauu9zhptghq9lzj7w8xara';
    const vrf = '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0';
    const rewardAccount = 'addr1uxa5pudxg77g3sdaddecmw8tvc6hmynywn49lltt4fmvn7cmpqcax';
    const metadataJson = {
      hash: 'pool1ntpzzu5g6xhqkns4csd435lqtgfjqm7e4wquk9v58eqhf0esey9st6vf29',
      url: 'https://example.com'
    };
    const params = coreToCsl.certificate
      .poolRegistration({
        cost: 1000n,
        id: stakeKey,
        margin: { denominator: 5, numerator: 1 },
        metadataJson,
        owners: [owner],
        pledge: 10_000n,
        relays: [
          { hostname: 'example.com', port: 5000, type: 'singlehost-by-name' },
          {
            ipv4: '127.0.0.1',
            port: 6000,
            type: 'singlehost-by-address'
          },
          { dnsName: 'example.com', type: 'multihost-by-name' }
        ],
        rewardAccount,
        vrf
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
    expect(params.operator().to_bech32('stake')).toBe(stakeKey);
    const relays = params.relays();
    expect(relays.len()).toBe(3);
    expect(Buffer.from(params.vrf_keyhash().to_bytes()).toString('hex')).toBe(vrf);
    expect(params.reward_account().to_address().to_bech32('addr')).toBe(rewardAccount);
    const metadata = params.pool_metadata()!;
    expect(metadata.url().url()).toBe(metadataJson.url);
    expect(metadata.pool_metadata_hash().to_bech32('pool')).toBe(metadataJson.hash);
  });

  it('poolRetirement', () => {
    const retirement = coreToCsl.certificate.poolRetirement(stakeKey, 1000).as_pool_retirement()!;
    expect(retirement.pool_keyhash().to_bech32('stake')).toEqual(stakeKey);
    expect(retirement.epoch()).toEqual(1000);
  });
});
