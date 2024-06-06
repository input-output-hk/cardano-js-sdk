import { AddressType, KeyRole } from '../types.js';
import type { Bip32Account } from '../Bip32Account.js';
import type { Cardano } from '@cardano-sdk/core';
import type { GroupedAddress } from '../types.js';
import type { Logger } from 'ts-log';

export interface EnsureStakeKeysParams {
  /** Key agent to use */
  bip32Account: Bip32Account;
  /** Look for existing stake keys used in those addresses */
  knownAddresses: GroupedAddress[];
  /** Requested number of stake keys */
  count: number;
  /** The payment key index to use when more stake keys are needed */
  paymentKeyIndex?: number;
  logger: Logger;
}

export type EnsureStakeKeysResult = {
  rewardAccounts: Cardano.RewardAccount[];
  newAddresses: GroupedAddress[];
};

/** Given a count, checks if enough stake keys exist and derives more if needed. Returns all reward accounts and new addresses */
export const ensureStakeKeys = async ({
  bip32Account,
  knownAddresses,
  count,
  logger,
  paymentKeyIndex: index = 0
}: EnsureStakeKeysParams): Promise<EnsureStakeKeysResult> => {
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
  const newAddresses: GroupedAddress[] = [];
  for (let stakeKeyIdx = 0; stakeKeys.size < count; stakeKeyIdx++) {
    if (!stakeKeys.has(stakeKeyIdx)) {
      const address = await bip32Account.deriveAddress({ index, type: AddressType.External }, stakeKeyIdx);
      newAddresses.push(address);
      logger.debug(
        `No derivation with stake key index ${stakeKeyIdx} exists. Derived a new stake key ${address.rewardAccount}.`
      );
      stakeKeys.set(stakeKeyIdx, address.rewardAccount);
    }
  }

  return {
    newAddresses,
    rewardAccounts: [...stakeKeys.values()]
  };
};
