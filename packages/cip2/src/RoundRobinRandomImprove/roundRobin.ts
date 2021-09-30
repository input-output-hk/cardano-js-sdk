import { BigIntMath } from '@cardano-sdk/core';
import {
  assetWithValueQuantitySelector,
  getWithValuesCoinQuantity,
  OutputWithValue,
  WithValue,
  UtxoSelection,
  UtxoWithValue
} from './util';

const improvesSelection = (
  utxoAlreadySelected: UtxoWithValue[],
  input: UtxoWithValue,
  minimumTarget: bigint,
  getQuantity: (totals: WithValue[]) => bigint
): boolean => {
  const oldQuantity = getQuantity(utxoAlreadySelected);
  // We still haven't reached the minimum target of
  // 100%. Therefore, we consider any potential input
  // to be an improvement:
  if (oldQuantity < minimumTarget) return true;
  const newQuantity = oldQuantity + getQuantity([input]);
  const idealTarget = 2n * minimumTarget;
  const newDistance = BigIntMath.abs(idealTarget - newQuantity);
  const oldDistance = BigIntMath.abs(idealTarget - oldQuantity);
  // Using this input will move us closer to the
  // ideal target of 200%, so we treat this as an improvement:
  if (newDistance < oldDistance) return true;
  // Adding the selected input would move us further
  // away from the target of 200%. Reaching this case
  // means we have already covered the minimum target
  // of 100%, and therefore it is safe to not consider
  // this token any further:
  return false;
};

const listTokensWithin = (uniqueOutputAssetIDs: string[], outputs: OutputWithValue[]) => [
  ...uniqueOutputAssetIDs.map((id) => {
    const getQuantity = assetWithValueQuantitySelector(id);
    return {
      getQuantity,
      minimumTarget: getQuantity(outputs),
      filterUtxo: (utxo: UtxoWithValue[]) => utxo.filter(({ value: { assets } }) => assets?.[id])
    };
  }),
  {
    // Lovelace
    getQuantity: (totals: WithValue[]) => getWithValuesCoinQuantity(totals),
    minimumTarget: getWithValuesCoinQuantity(outputs),
    filterUtxo: (utxo: UtxoWithValue[]) => utxo
  }
];

/**
 * Round-Robin selection algorithm.
 *
 * Assumes we have already checked that the available UTxO balance is sufficient to cover all tokens in the outputs.
 * Considers all outputs collectively, as a combined output bundle.
 */
export const roundRobinSelection = (
  availableUtxo: UtxoWithValue[],
  outputs: OutputWithValue[],
  uniqueOutputAssetIDs: string[]
): UtxoSelection => {
  // The subset of the UTxO that has already been selected:
  const utxoSelected: UtxoWithValue[] = [];
  // The subset of the UTxO that remains available for selection:
  const utxoRemaining = [...availableUtxo];
  // The set of tokens that we still need to cover:
  const tokensRemaining = listTokensWithin(uniqueOutputAssetIDs, outputs);
  while (tokensRemaining.length > 0) {
    // Consider each token in round-robin fashion:
    for (const [tokenIdx, { filterUtxo, minimumTarget, getQuantity }] of tokensRemaining.entries()) {
      // Attempt to select at random an input that includes
      // this token from the remaining UTxO set:
      const utxo = filterUtxo(utxoRemaining);
      if (utxo.length > 0) {
        const inputIdx = Math.floor(Math.random() * utxo.length);
        const input = utxo[inputIdx];
        if (improvesSelection(utxoSelected, input, minimumTarget, getQuantity)) {
          utxoSelected.push(input);
          utxoRemaining.splice(utxoRemaining.indexOf(input), 1);
        } else {
          // The selection was not improved by including
          // this input. If we've reached this point, it
          // means that we've already covered the minimum
          // target of 100%, and therefore it is safe to
          // not consider this token any further.
          tokensRemaining.splice(tokenIdx, 1);
        }
      } else {
        // The attempt to select an input failed (there were
        // no inputs remaining that contained the token).
        // This means that we've already covered the minimum
        // quantity required (due to the pre-condition), and
        // therefore it is safe to not consider this token
        // any further:
        tokensRemaining.splice(tokenIdx, 1);
      }
    }
  }
  return { utxoSelected, utxoRemaining };
};
