import {
  createChainSyncClient,
  StateQuery,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema,
  ConnectionConfig,
  createInteractionContext
} from '@cardano-ogmios/client';
import { GeneratorMetadata } from '../Content';
import { isByronStandardBlock } from '../util';
import { applyValue } from './applyValue';

export type AddressBalances = {
  [address: string]: Schema.Value;
};

export type AddressBalancesResponse = GeneratorMetadata & {
  balances: { [blockHeight: string]: AddressBalances };
};

// eslint-disable-next-line func-style
export async function getOnChainAddressBalances(
  addresses: string[],
  atBlocks: number[],
  options?: {
    ogmiosConnectionConfig: ConnectionConfig;
    onBlock?: (slot: number) => void;
  }
): Promise<AddressBalancesResponse> {
  const trackedAddressBalances: AddressBalances = Object.fromEntries(
    addresses.map((address) => [address, { coins: 0, assets: {} }])
  );
  const trackedTxs: ({ id: Schema.Hash16 } & Schema.Tx)[] = [];
  return new Promise(async (resolve, reject) => {
    let currentBlock: number;
    // Required to ensure existing messages in the pipe are not processed after the completion
    // condition is met
    let draining = false;
    const response: AddressBalancesResponse = {
      metadata: {
        cardano: {
          compactGenesis: await StateQuery.genesisConfig(
            await createInteractionContext(reject, console.log, { connection: options.ogmiosConnectionConfig })
          ),
          intersection: undefined
        }
      },
      balances: {}
    };
    try {
      const syncClient = await createChainSyncClient(
        await createInteractionContext(reject, console.log, { connection: options.ogmiosConnectionConfig }),
        {
          rollBackward: async (_res, requestNext) => {
            requestNext();
          },
          rollForward: async ({ block }, requestNext) => {
            if (draining) return;
            let b: Schema.StandardBlock | Schema.BlockShelley | Schema.BlockAllegra | Schema.BlockMary;
            let blockBody:
              | Schema.StandardBlock['body']['txPayload']
              | Schema.BlockShelley['body']
              | Schema.BlockAllegra['body']
              | Schema.BlockMary['body'];
            if (isByronStandardBlock(block)) {
              b = block.byron as Schema.StandardBlock;
              blockBody = b.body.txPayload;
            } else if (isShelleyBlock(block)) {
              b = block.shelley as Schema.BlockShelley;
              blockBody = b.body;
            } else if (isAllegraBlock(block)) {
              b = block.allegra as Schema.BlockAllegra;
              blockBody = b.body;
            } else if (isMaryBlock(block)) {
              b = block.mary as Schema.BlockMary;
              blockBody = b.body;
            }
            if (b !== undefined) {
              currentBlock = b.header.blockHeight;
              if (options?.onBlock !== undefined) {
                options.onBlock(currentBlock);
              }
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
      response.metadata.cardano.intersection = await syncClient.startSync(['origin']);
    } catch (error) {
      console.error(error);
      return reject(error);
    }
  });
}
