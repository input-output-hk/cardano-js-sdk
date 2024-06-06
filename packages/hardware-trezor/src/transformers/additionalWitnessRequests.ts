import { isNotNil } from '@cardano-sdk/util';
import { resolvePaymentKeyPathForTxIn } from './keyPaths.js';
import { util } from '@cardano-sdk/key-management';
import isArray from 'lodash/isArray.js';
import uniq from 'lodash/uniq.js';
import type * as Trezor from '@trezor/connect';
import type { Cardano } from '@cardano-sdk/core';
import type { Transform } from '@cardano-sdk/util';
import type { TrezorTxTransformerContext } from '../types.js';

export const mapAdditionalWitnessRequests: Transform<
  Cardano.TxIn[],
  Trezor.DerivationPath[],
  TrezorTxTransformerContext
> = (inputs, context) => {
  const paymentKeyPaths = uniq<Trezor.DerivationPath>(
    inputs
      .map((input) => resolvePaymentKeyPathForTxIn(input, context))
      .filter(isNotNil)
      .filter(isArray)
  );

  const additionalWitnessPaths: Trezor.DerivationPath[] = [...paymentKeyPaths];

  if (context?.knownAddresses?.length) {
    const stakeKeyPath = util.stakeKeyPathFromGroupedAddress(context.knownAddresses[0]);
    if (stakeKeyPath) additionalWitnessPaths.push(stakeKeyPath);
  }
  return additionalWitnessPaths;
};
