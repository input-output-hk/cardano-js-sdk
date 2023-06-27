import { AddressType, AsyncKeyAgent, GroupedAddress, KeyRole } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { firstValueFrom } from 'rxjs';
import uniq from 'lodash/uniq';

export interface EnsureStakeKeysParams {
  /** Key agent to use */
  keyAgent: AsyncKeyAgent;
  /** Requested number of stake keys */
  count: number;
  /** The payment key index to use when more stake keys are needed */
  paymentKeyIndex?: number;
  logger: Logger;
}

/**
 * Given a count, checks if enough stake keys exist and derives
 * more if needed.
 * Returns the newly created reward accounts
 */
export const ensureStakeKeys = async ({
  keyAgent,
  count,
  logger,
  paymentKeyIndex: index = 0
}: EnsureStakeKeysParams): Promise<Cardano.RewardAccount[]> => {
  const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
  // Get current number of derived stake keys
  const stakeKeyIndices = uniq(
    knownAddresses
      .filter(
        ({ stakeKeyDerivationPath }) =>
          stakeKeyDerivationPath?.role === KeyRole.Stake && stakeKeyDerivationPath?.index !== undefined
      )
      .map(({ stakeKeyDerivationPath }) => stakeKeyDerivationPath!.index)
  );

  const countToDerive = count - stakeKeyIndices.length;

  if (countToDerive <= 0) {
    // Sufficient stake keys are already created
    return [];
  }

  logger.debug(`Stake keys requested: ${count}; got ${stakeKeyIndices.length}`);

  // Need more stake keys for the portfolio
  const derivedAddresses: Promise<GroupedAddress>[] = [];
  for (let stakeKeyIdx = 0; derivedAddresses.length < countToDerive; stakeKeyIdx++) {
    if (!stakeKeyIndices.includes(stakeKeyIdx)) {
      logger.debug(`No derivation with stake key index ${stakeKeyIdx} exists. Deriving a new stake key.`);
      derivedAddresses.push(keyAgent.deriveAddress({ index, type: AddressType.External }, stakeKeyIdx));
    }
  }

  const newAddresses = await Promise.all(derivedAddresses);
  logger.debug('Derived new addresses:', newAddresses);
  return newAddresses.map(({ rewardAccount }) => rewardAccount);
};
