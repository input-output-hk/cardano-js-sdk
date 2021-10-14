import { Utxo } from '@cardano-ogmios/schema';
import { Ogmios } from '@cardano-sdk/core';
import Emittery from 'emittery';
import { dummyLogger } from 'ts-log';
import { UtxoRepository, UtxoRepositoryEvent, UtxoRepositoryFields } from './types';

export interface Balance extends Ogmios.Value {
  rewards: Ogmios.Lovelace;
}

export interface Balances {
  total: Balance;
  available: Balance;
}

export enum BalanceTrackerEvent {
  Changed = 'changed'
}

export interface BalanceTrackerEvents {
  changed: Balances;
}

export class BalanceTracker extends Emittery<BalanceTrackerEvents> implements Balances {
  total!: Balance;
  available!: Balance;

  constructor(utxoRepository: UtxoRepository, logger = dummyLogger) {
    super();
    this.#updateBalances(utxoRepository);
    utxoRepository.on(UtxoRepositoryEvent.Changed, (fields) => {
      this.#updateBalances(fields);
      this.emit(BalanceTrackerEvent.Changed, {
        available: this.available,
        total: this.total
      }).catch(logger.error);
    });
  }

  #updateBalances(utxoRepository: UtxoRepositoryFields) {
    this.total = {
      ...this.#getBalance(utxoRepository.allUtxos),
      rewards: utxoRepository.allRewards || 0n
    };
    this.available = {
      ...this.#getBalance(utxoRepository.availableUtxos),
      rewards: utxoRepository.availableRewards || 0n
    };
  }

  #getBalance(utxo: Utxo): Ogmios.Value {
    return Ogmios.util.coalesceValueQuantities(
      utxo.map(([_, txOut]) => {
        const { coins, assets } = txOut.value;
        return {
          coins: BigInt(coins),
          assets
        };
      })
    );
  }
}
