/* eslint-disable complexity */
/* eslint-disable unicorn/no-nested-ternary */
import { BigIntMath } from '@cardano-sdk/util';
import { Ogmios } from '@cardano-sdk/ogmios';

const throwIfNegative = (value: bigint | number): void => {
  if (value < 0) {
    throw new Error('The value provided cannot be applied as it will result in a negative balance');
  }
};

export const applyValue = (
  balance: Ogmios.Schema.Value,
  value: Ogmios.Schema.Value,
  spending = false
  // eslint-disable-next-line sonarjs/cognitive-complexity
): Ogmios.Schema.Value => {
  // This is a workaround. coins is typed as a bigint,
  // but it's sometimes being parsed from the raw response as a number.
  const valueCoins: bigint = typeof value.ada.lovelace === 'bigint' ? value.ada.lovelace : BigInt(value.ada.lovelace);
  const balanceCoins: bigint =
    typeof balance.ada.lovelace === 'bigint' ? balance.ada.lovelace : BigInt(balance.ada.lovelace);
  const coins = balanceCoins + (spending ? -BigIntMath.abs(valueCoins) : valueCoins);
  throwIfNegative(coins);
  const balanceToApply: Ogmios.Schema.Value = { ...balance, ada: { lovelace: coins } };
  const assets = Object.entries(value ?? {}).filter(([policyId]) => policyId !== 'ada');

  for (const [policyId, asset] of assets) {
    for (const [assetName, qty] of Object.entries(asset)) {
      const assetQty = spending ? -BigIntMath.abs(qty) : qty;
      const balanceQty = balance[policyId]?.[assetName];
      balanceToApply[policyId] = {
        ...balanceToApply[policyId],
        [assetName]: balanceQty !== undefined ? balanceQty + assetQty : assetQty
      };
      throwIfNegative(balanceToApply[policyId]?.[assetName]);
    }
  }

  return balanceToApply;
};
