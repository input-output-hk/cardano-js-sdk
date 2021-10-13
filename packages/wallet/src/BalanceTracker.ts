import { Ogmios } from '@cardano-sdk/core';

export interface Balance extends Ogmios.Value {
  rewards: Ogmios.Lovelace;
}

export interface Balances {
  total: Balance;
  available: Balance;
}

export interface BalanceTrackerEvents {
  balanceChanged: Balances;
}

// export class BalanceTracker extends Emittery<BalanceTrackerEvents> implements Balances {
//   total: Balance;
//   available: Balance;

//   constructor(utxoRepository: UtxoRepository) {
//     super();
//     const totalValue = this.#getBalance(utxoRepository.allUtxos);
//     const availableValue = this.#getBalance(utxoRepository.availableUtxos);
//     const totalRewards = utxoRepository.rewards;
//     const availableRewards = utxoRepository.availableRewards;
//   }

//   #getBalance(utxo: Utxo): Ogmios.Value {
//     return Ogmios.util.coalesceValueQuantities(
//       utxo.map(([_, txOut]) => {
//         const { coins, assets } = txOut.value;
//         return {
//           coins: BigInt(coins),
//           assets
//         };
//       })
//     );
//   }
// }
