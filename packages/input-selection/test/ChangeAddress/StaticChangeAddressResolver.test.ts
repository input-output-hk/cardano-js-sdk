import { AddressType, GroupedAddress, KeyRole } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';
import { InvalidStateError } from '@cardano-sdk/util';
import { StaticChangeAddressResolver } from '../../src';

export const knownAddresses = () =>
  Promise.resolve([
    {
      accountIndex: 0,
      address: 'testAddress' as Cardano.PaymentAddress,
      index: 0,
      networkId: Cardano.NetworkId.Testnet,
      rewardAccount: '' as Cardano.RewardAccount,
      stakeKeyDerivationPath: { index: 0, role: KeyRole.Stake },
      type: AddressType.External
    }
  ]);

const emptyKnownAddresses = () => Promise.resolve(new Array<GroupedAddress>());

describe('StaticChangeAddressResolver', () => {
  it('always resolves to the first address in the knownAddresses', async () => {
    const changeAddressResolver = new StaticChangeAddressResolver(knownAddresses);

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 10n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 20n }
        },
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 30n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    const updatedChange = await changeAddressResolver.resolve(selection);
    expect(updatedChange).toEqual([
      { address: 'testAddress', value: { coins: 10n } },
      { address: 'testAddress', value: { coins: 20n } },
      { address: 'testAddress', value: { coins: 30n } }
    ]);
  });

  it('throws InvalidStateError if the there are no known addresses', async () => {
    const changeAddressResolver = new StaticChangeAddressResolver(emptyKnownAddresses);

    const selection = {
      change: [
        {
          address: '_' as Cardano.PaymentAddress,
          value: { coins: 0n }
        }
      ],
      fee: 0n,
      inputs: new Set<Cardano.Utxo>(),
      outputs: new Set<Cardano.TxOut>()
    };

    await expect(changeAddressResolver.resolve(selection)).rejects.toThrow(
      new InvalidStateError('The wallet has no known addresses.')
    );
  });
});
