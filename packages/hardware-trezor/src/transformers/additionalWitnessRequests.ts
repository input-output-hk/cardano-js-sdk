import * as Trezor from '@trezor/connect';
import { Cardano } from '@cardano-sdk/core';
import { Transform, isNotNil } from '@cardano-sdk/util';
import { TrezorTxTransformerContext } from '../types';
import { resolvePaymentKeyPathForTxIn } from './keyPaths';
import { util } from '@cardano-sdk/key-management';
import isArray from 'lodash/isArray';
import uniq from 'lodash/uniq';

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
    const stakeKeyPath = util.stakeKeyPathFromGroupedAddress({ address: context.knownAddresses[0] });
    if (stakeKeyPath) additionalWitnessPaths.push(stakeKeyPath);
  }
  return additionalWitnessPaths;
};
