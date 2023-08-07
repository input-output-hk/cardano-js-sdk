import * as Trezor from 'trezor-connect';
import { CardanoKeyConst, GroupedAddress, util } from '@cardano-sdk/key-management';
import { TrezorTxTransformerContext } from '../types';
import { isNotNil } from '@cardano-sdk/util';
import concat from 'lodash/concat';
import uniq from 'lodash/uniq';

export const createRewardAccountKeyPath = (knownAddress: GroupedAddress) => [
  util.harden(CardanoKeyConst.PURPOSE),
  util.harden(CardanoKeyConst.COIN_TYPE),
  util.harden(knownAddress.accountIndex),
  util.STAKE_KEY_DERIVATION_PATH.role,
  util.STAKE_KEY_DERIVATION_PATH.index
];

export const mapAdditionalWitnessRequests = (inputs: Trezor.CardanoInput[], context: TrezorTxTransformerContext) => {
  const paymentKeyPaths = uniq(inputs.map((i) => i.path).filter(isNotNil));
  const additionalWitnessPaths = concat([], paymentKeyPaths);
  if (context.knownAddresses.length > 0) {
    additionalWitnessPaths.push(createRewardAccountKeyPath(context.knownAddresses[0]));
  }
  return additionalWitnessPaths;
};
