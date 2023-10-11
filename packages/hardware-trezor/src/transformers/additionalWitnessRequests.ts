import * as Trezor from '@trezor/connect';
import { BIP32Path } from '@cardano-sdk/crypto';
import { TrezorTxTransformerContext } from '../types';
import { isNotNil } from '@cardano-sdk/util';
import { util } from '@cardano-sdk/key-management';
import isArray from 'lodash/isArray';
import uniq from 'lodash/uniq';

export const mapAdditionalWitnessRequests = (inputs: Trezor.CardanoInput[], context: TrezorTxTransformerContext) => {
  const paymentKeyPaths = uniq<BIP32Path>(
    inputs
      .map((i) => i.path)
      .filter(isNotNil)
      .filter(isArray)
  );
  const additionalWitnessPaths: BIP32Path[] = [...paymentKeyPaths];
  if (context.knownAddresses.length > 0) {
    const stakeKeyPath = util.stakeKeyPathFromGroupedAddress(context.knownAddresses[0]);
    if (stakeKeyPath) additionalWitnessPaths.push(stakeKeyPath);
  }
  return additionalWitnessPaths;
};
