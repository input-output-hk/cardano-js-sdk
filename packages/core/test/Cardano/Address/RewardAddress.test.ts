import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors';
import { Cardano } from '../../../src';

describe('Cardano/Address/RewardAddress', () => {
  it('fromCredentials can build the correct RewardAddress instance', () => {
    const address = Cardano.RewardAddress.fromCredentials(
      Cardano.NetworkId.Mainnet,
      cip19TestVectors.KEY_STAKING_CREDENTIAL
    );
    expect(address.toAddress().toBech32()).toEqual(cip19TestVectors.rewardKey);
  });
});
