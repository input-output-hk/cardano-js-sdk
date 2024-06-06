/* eslint-disable complexity */
import { Ogmios, ogmiosToCore } from '@cardano-sdk/ogmios';
import { applyValue } from './applyValue.js';
import type { GeneratorMetadata } from '../Content.js';
import type { Intersection } from '@cardano-sdk/core';
import type { Logger } from 'ts-log';

export type AddressBalances = {
  [address: string]: Ogmios.Schema.Value;
};

export type AddressBalancesResponse = GeneratorMetadata & {
  balances: { [blockHeight: string]: AddressBalances };
};

export const getOnChainAddressBalances = (
  addresses: string[],
  atBlocks: number[],
  options: {
    logger: Logger;
    ogmiosConnectionConfig: Ogmios.ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<AddressBalancesResponse> => {
  const { logger, ogmiosConnectionConfig, onBlock } = options;
  const trackedAddressBalances: AddressBalances = Object.fromEntries(
    addresses.map((address) => [address, { assets: {}, coins: 0n }])
  );
  const trackedTxs: { id: Ogmios.Schema.TxId; inputs: Ogmios.Schema.TxIn[]; outputs: Ogmios.Schema.TxOut[] }[] = [];
  // eslint-disable-next-line sonarjs/cognitive-complexity
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion
    // condition is met
    let draining = false;
    const response: AddressBalancesResponse = {
      balances: {},
      metadata: {
        cardano: {
          compactGenesis: ogmiosToCore.genesis(
            await Ogmios.StateQuery.genesisConfig(
              await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig })
            )
          ),
          intersection: undefined as unknown as Intersection
        }
      }
    };
    try {
      const syncClient = await Ogmios.createChainSyncClient(
        await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          // eslint-disable-next-line max-statements
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let b:
              | Ogmios.Schema.BlockByron
              | Ogmios.Schema.StandardBlock
              | Ogmios.Schema.BlockShelley
              | Ogmios.Schema.BlockAllegra
              | Ogmios.Schema.BlockMary
              | Ogmios.Schema.BlockAlonzo
              | Ogmios.Schema.BlockBabbage;
            let blockBody:
              | undefined
              | Ogmios.Schema.StandardBlock['body']['txPayload']
              | Ogmios.Schema.BlockShelley['body']
              | Ogmios.Schema.BlockAllegra['body']
              | Ogmios.Schema.BlockMary['body']
              | Ogmios.Schema.BlockAlonzo['body']
              | Ogmios.Schema.BlockBabbage['body'];
            if (Ogmios.isByronStandardBlock(block)) {
              b = block.byron as Ogmios.Schema.StandardBlock;
              blockBody = b.body.txPayload;
            } else if (Ogmios.isShelleyBlock(block)) {
              b = block.shelley as Ogmios.Schema.BlockShelley;
              blockBody = b.body;
            } else if (Ogmios.isAllegraBlock(block)) {
              b = block.allegra as Ogmios.Schema.BlockAllegra;
              blockBody = b.body;
            } else if (Ogmios.isMaryBlock(block)) {
              b = block.mary as Ogmios.Schema.BlockMary;
              blockBody = b.body;
            } else if (Ogmios.isAlonzoBlock(block)) {
              b = block.alonzo as Ogmios.Schema.BlockAlonzo;
              blockBody = b.body;
            } else if (Ogmios.isBabbageBlock(block)) {
              b = block.babbage as Ogmios.Schema.BlockBabbage;
              blockBody = b.body;
            } else if (Ogmios.isByronEpochBoundaryBlock(block)) {
              b = block.byron as Ogmios.Schema.BlockByron;
            } else {
              throw new Error('No support for block');
            }
            if (b !== undefined) {
              currentBlock = b.header!.blockHeight;
              if (onBlock !== undefined) {
                onBlock(currentBlock);
              }
              if (blockBody) {
                for (const tx of blockBody) {
                  for (const output of tx.body.outputs) {
                    if (trackedAddressBalances[output.address] !== undefined) {
                      const addressBalance = { ...trackedAddressBalances[output.address] };
                      trackedTxs.push({ id: tx.id, inputs: tx.body.inputs, outputs: tx.body.outputs });
                      trackedAddressBalances[output.address] = applyValue(addressBalance, output.value);
                    }
                  }
                  for (const input of tx.body.inputs) {
                    const trackedInput = trackedTxs.find((t) => t.id === input.txId)?.outputs[input.index];
                    if (trackedInput !== undefined && trackedAddressBalances[trackedInput?.address] !== undefined) {
                      const addressBalance = { ...trackedAddressBalances[trackedInput.address] };
                      trackedAddressBalances[trackedInput.address] = applyValue(
                        addressBalance,
                        trackedInput.value,
                        true
                      );
                    }
                  }
                }
                if (atBlocks.includes(currentBlock)) {
                  response.balances[currentBlock] = { ...trackedAddressBalances };
                  if (atBlocks[atBlocks.length - 1] === currentBlock) {
                    draining = true;
                    await syncClient.shutdown();
                    return resolve(response);
                  }
                }
              }
            }
            requestNext();
          }
        }
      );
      response.metadata.cardano.intersection = (await syncClient.startSync(['origin'])) as Intersection;
    } catch (error) {
      logger.error(error);
      return reject(error);
    }
  });
};
