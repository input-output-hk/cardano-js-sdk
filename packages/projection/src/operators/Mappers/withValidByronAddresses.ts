import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import { WithConsumedTxIn, WithProducedUTxO, WithUtxo } from './withUtxo';
import { unifiedProjectorOperator } from '../utils';

const MAX_BYRON_OUTPUT_ADDRESS_BYTES_LENGTH = 8191;
const ICARUS_ADDR_BECH32_PREFIX = 'Ae2';
const DAEDALUS_ADDR_BECH32_PREFIX = 'DdzFF';

const isBFT = ({ type }: Cardano.Block) => type === 'bft';
const hasByronAddressPrefix = (address: string): boolean =>
  address.startsWith(ICARUS_ADDR_BECH32_PREFIX) || address.startsWith(DAEDALUS_ADDR_BECH32_PREFIX);

const transformByronAddress = (address: Cardano.PaymentAddress) => {
  if (!hasByronAddressPrefix(address) || address.length > 200) {
    const byronAddress = Cardano.Address.fromBase58(address);
    const keyHashBytes = Buffer.from(byronAddress.toBytes(), 'hex');
    if (keyHashBytes.length > MAX_BYRON_OUTPUT_ADDRESS_BYTES_LENGTH) {
      const byronBase16CredentialHash = Crypto.Hash28ByteBase16(Crypto.blake2b(28).update(keyHashBytes).digest('hex'));
      return Cardano.ByronAddress.fromCredentials(
        byronBase16CredentialHash,
        byronAddress.getProps().byronAddressContent!.attrs!,
        byronAddress.getProps().byronAddressContent!.type!
      )
        .toAddress()
        .toBase58();
    }
  }
  return address;
};

/**
 * This mapper transforms invalid (very long) Byron output addresses by re-hashing them
 * such so their length does not exceed the maximum defined row index of postgres.
 *
 * Example Tx (Mainnet):
 * {@link https://cardanoscan.io/transaction/bc61865d72bd8a0956f1b12595e314a60cc8e3f4350c044b2a86f3230ace923a?tab=summary bc61865d72bd8a0956f1b12595e314a60cc8e3f4350c044b2a86f3230ace923a}
 */
export const withValidByronAddresses = unifiedProjectorOperator<WithUtxo, WithUtxo>((evt) => {
  if (isBFT(evt.block)) {
    const txToUtxos = new Map<Cardano.TransactionId, WithConsumedTxIn & WithProducedUTxO>();

    for (const txId of Object.keys(evt.utxoByTx) as Cardano.TransactionId[]) {
      txToUtxos.set(txId, {
        consumed: evt.utxoByTx[txId]!.consumed,
        produced: evt.utxoByTx[txId]!.produced.map(([txIn, txOut]): [Cardano.TxIn, Cardano.TxOut] => [
          txIn,
          { ...txOut, address: transformByronAddress(txOut.address) }
        ])
      });
    }

    const utxoByTx = Object.fromEntries(txToUtxos);
    return {
      ...evt,
      utxo: {
        consumed: evt.utxo.consumed,
        produced: Object.values(utxoByTx).flatMap((tx) => tx.produced)
      },
      utxoByTx
    };
  }
  return evt;
});
