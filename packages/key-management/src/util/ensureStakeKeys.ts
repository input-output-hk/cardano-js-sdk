import { AddressType, AsyncKeyAgent, KeyRole } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { firstValueFrom } from 'rxjs';

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
 * Returns all reward accounts
 */
export const ensureStakeKeys = async ({
  keyAgent,
  count,
  logger,
  paymentKeyIndex: index = 0
}: EnsureStakeKeysParams): Promise<Cardano.RewardAccount[]> => {
  const knownAddresses = await firstValueFrom(keyAgent.knownAddresses$);
  const stakeKeys = new Map(
    knownAddresses
      .filter(
        ({ stakeKeyDerivationPath }) =>
          stakeKeyDerivationPath?.role === KeyRole.Stake && stakeKeyDerivationPath?.index !== undefined
      )
      .map(({ rewardAccount, stakeKeyDerivationPath }) => [stakeKeyDerivationPath!.index, rewardAccount])
  );

  logger.debug(`Stake keys requested: ${count}; got ${stakeKeys.size}`);

  // Need more stake keys for the portfolio
  for (let stakeKeyIdx = 0; stakeKeys.size < count; stakeKeyIdx++) {
    if (!stakeKeys.has(stakeKeyIdx)) {
      const address = await keyAgent.deriveAddress({ index, type: AddressType.External }, stakeKeyIdx);
      logger.debug(
        `No derivation with stake key index ${stakeKeyIdx} exists. Derived a new stake key ${address.rewardAccount}.`
      );
      stakeKeys.set(stakeKeyIdx, address.rewardAccount);
    }
  }

  return [...stakeKeys.values()];
};
