/* eslint-disable complexity */
import { GeneratorMetadata } from '../Content';
import { Intersection } from '@cardano-sdk/core';
import { Logger } from 'ts-log';
import { Ogmios, ogmiosToCore } from '@cardano-sdk/ogmios';
import { applyValue } from './applyValue';
import { ogmiosIntersectionToCore } from '../util';

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
    addresses.map((address) => [address, { ada: { lovelace: 0n }, assets: {} }])
  );
  const trackedTxs: {
    id: Ogmios.Schema.TransactionId;
    inputs: Ogmios.Schema.TransactionOutputReference[];
    outputs: Ogmios.Schema.TransactionOutput[];
  }[] = [];
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
            await Ogmios.LedgerStateQuery.genesisConfiguration(
              await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig }),
              'shelley'
            )
          ),
          intersection: undefined as unknown as Intersection
        }
      }
    };
    try {
      const syncClient = await Ogmios.createChainSynchronizationClient(
        await Ogmios.createInteractionContext(reject, logger.info, { connection: ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          // eslint-disable-next-line max-statements
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let blockBody: Ogmios.Schema.Transaction[];
            switch (block.era) {
              case 'allegra':
              case 'alonzo':
              case 'babbage':
              case 'shelley':
              case 'mary':
                blockBody = block.transactions || [];
                break;
              case 'byron':
                blockBody = block.type === 'ebb' ? [] : block.transactions || [];
                break;
              default:
                throw new Error('No support for block');
            }

            currentBlock = block.height;
            if (onBlock !== undefined) {
              onBlock(currentBlock);
            }
            if (blockBody) {
              for (const tx of blockBody) {
                for (const output of tx.outputs) {
                  if (trackedAddressBalances[output.address] !== undefined) {
                    const addressBalance = { ...trackedAddressBalances[output.address] };
                    trackedTxs.push({ id: tx.id, inputs: tx.inputs, outputs: tx.outputs });
                    trackedAddressBalances[output.address] = applyValue(addressBalance, output.value);
                  }
                }
                for (const input of tx.inputs) {
                  const trackedInput = trackedTxs.find((t) => t.id === input.transaction.id)?.outputs[input.index];
                  if (trackedInput !== undefined && trackedAddressBalances[trackedInput?.address] !== undefined) {
                    const addressBalance = { ...trackedAddressBalances[trackedInput.address] };
                    trackedAddressBalances[trackedInput.address] = applyValue(addressBalance, trackedInput.value, true);
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
            requestNext();
          }
        }
      );
      response.metadata.cardano.intersection = ogmiosIntersectionToCore(await syncClient.resume(['origin']));
    } catch (error) {
      logger.error(error);
      return reject(error);
    }
  });
};
