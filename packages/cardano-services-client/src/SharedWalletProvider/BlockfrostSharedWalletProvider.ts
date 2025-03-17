import * as Crypto from '@cardano-sdk/crypto';
import { BlockfrostClient, BlockfrostProvider, fetchSequentially } from '../blockfrost';
import { Cardano, MULTISIG_CIP_ID, Serialization } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { MultiSigRegistration, MultiSigTransaction, SharedWalletProvider } from './types';
import type { Responses } from '@blockfrost/blockfrost-js';

const MULTI_SIG_LABEL = MULTISIG_CIP_ID;

const isMultiSigRegistration = (metadata: unknown): metadata is MultiSigRegistration =>
  !!metadata && typeof metadata === 'object' && 'participants' in metadata;

export class BlockfrostSharedWalletProvider extends BlockfrostProvider implements SharedWalletProvider {
  constructor(client: BlockfrostClient, logger: Logger) {
    super(client, logger);
  }

  private async getNativeScripts(txId: Cardano.TransactionId): Promise<Cardano.Script[]> {
    const response = await this.request<Responses['tx_content_cbor']>(`txs/${txId}/cbor`);
    const transaction = Serialization.Transaction.fromCbor(Serialization.TxCBOR(response.cbor)).toCore();
    return transaction.auxiliaryData?.scripts ?? [];
  }

  async discoverWallets(pubKey: Crypto.Ed25519KeyHashHex): Promise<MultiSigTransaction[]> {
    const batchSize = 100;

    const multiSigTransactions = await fetchSequentially<Responses['tx_metadata_label_json'][0], MultiSigTransaction>(
      {
        haveEnoughItems: (wallets, _) => wallets.length < batchSize,
        paginationOptions: { count: batchSize },
        request: (paginationQueryString) =>
          this.request<Responses['tx_metadata_label_json']>(
            `metadata/txs/labels/${MULTI_SIG_LABEL}?${paginationQueryString}`
          ),
        responseTranslator: (wallets) =>
          wallets
            .filter((wallet) => {
              const metadata = wallet.json_metadata;
              return isMultiSigRegistration(metadata) && metadata?.participants?.[pubKey];
            })
            .map((wallet) => ({
              metadata: wallet.json_metadata as unknown as MultiSigRegistration,
              nativeScripts: [],
              txId: Cardano.TransactionId(wallet.tx_hash)
            }))
      },
      []
    );

    return await Promise.all(
      multiSigTransactions.map(async (wallet) => ({
        ...wallet,
        nativeScripts: await this.getNativeScripts(wallet.txId)
      }))
    );
  }
}
