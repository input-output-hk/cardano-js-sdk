import {
  createChainSyncClient,
  genesisConfig,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema, ConnectionConfig
} from '@cardano-ogmios/client'
import { GeneratorMetadata } from '../Content'
import { isByronStandardBlock } from '../util'

type AddressBalances = {
  [address: string]: Schema.Value
}

export type AddressBalancesResponse = GeneratorMetadata & {
  balances: { [blockHeight: string]: AddressBalances }
}

export async function getOnChainAddressBalances (
  addresses: string[],
  atBlocks: number[],
  options?: {
    ogmiosConnectionConfig: ConnectionConfig
    progress?: {
      callback: (slot: number) => void
      interval: number
    }
  }
): Promise<AddressBalancesResponse> {
  const trackedAddressBalances: AddressBalances = Object.fromEntries(
    addresses.map(address => [address, { coins: 0, assets: {} }])
  )
  const response: AddressBalancesResponse = {
    metadata: {
      cardano: {
        compactGenesis: await genesisConfig(options?.ogmiosConnectionConfig),
        intersection: undefined
      }
    },
    balances: {}
  }
  const trackedTxs: ({ id: Schema.Hash16 } & Schema.Tx)[] = []
  const applyValue = (
    address: string,
    value: Schema.Value,
    subtract = false
  ): Schema.Value => {
    const addressBalance = trackedAddressBalances[address]
    if (addressBalance !== undefined) {
      const balanceToApply: Schema.Value = {
        assets: addressBalance.assets ?? {},
        coins: addressBalance.coins + (subtract ? -Math.abs(value.coins) : value.coins)
      }
      const outputAssets = Object.entries(value.assets ?? {})
      if (outputAssets.length > 0) {
        outputAssets.forEach(([assetId, qty]) => {
          balanceToApply.assets[assetId] = (addressBalance.assets[assetId] !== undefined)
            ? addressBalance.assets[assetId] + (subtract ? -Math.abs(qty) : qty)
            : (subtract ? -Math.abs(qty) : qty)
        })
      }
      return balanceToApply
    }
  }
  // eslint-disable-next-line no-async-promise-executor
  return new Promise(async (resolve, reject) => {
    let currentBlock: number
    let progressInterval: ReturnType<typeof setInterval>
    if (options?.progress) {
      progressInterval = setInterval(() => {
        if (currentBlock === undefined) return
        options.progress.callback(currentBlock)
      }, options.progress.interval)
    }
    // Required to ensure existing messages in the pipe are not processed after the completion
    // condition is met
    let draining = false
    try {
      const syncClient = await createChainSyncClient({
        rollBackward: async (_res, requestNext) => {
          requestNext()
        },
        rollForward: async ({ block }, requestNext) => {
          if (draining) return
          let b: Schema.StandardBlock
              | Schema.BlockShelley
              | Schema.BlockAllegra
              | Schema.BlockMary
          let blockBody: Schema.StandardBlock['body']['txPayload']
              | Schema.BlockShelley['body']
              | Schema.BlockAllegra['body']
              | Schema.BlockMary['body']
          if (isByronStandardBlock(block)) {
            b = block.byron as Schema.StandardBlock
            blockBody = b.body.txPayload
          } else if (isShelleyBlock(block)) {
            b = block.shelley as Schema.BlockShelley
            blockBody = b.body
          } else if (isAllegraBlock(block)) {
            b = block.allegra as Schema.BlockAllegra
            blockBody = b.body
          } else if (isMaryBlock(block)) {
            b = block.mary as Schema.BlockMary
            blockBody = b.body
          }
          if (b !== undefined) {
            currentBlock = b.header.blockHeight
            for (const tx of blockBody) {
              for (const output of tx.body.outputs) {
                const addressBalance = trackedAddressBalances[output.address]
                if (addressBalance !== undefined) {
                  trackedTxs.push({ id: tx.id, inputs: tx.body.inputs, outputs: tx.body.outputs })
                  trackedAddressBalances[output.address] = applyValue(
                    output.address, output.value
                  )
                }
              }
              for (const input of tx.body.inputs) {
                const trackedInput = trackedTxs.find(t => t.id === input.txId)?.outputs[input.index]
                if (trackedInput !== undefined) {
                  const addressBalance = trackedAddressBalances[trackedInput?.address]
                  if (addressBalance !== undefined) {
                    trackedAddressBalances[trackedInput.address] = applyValue(
                      trackedInput.address, trackedInput.value, true
                    )
                  }
                }
              }
            }
            if (atBlocks.includes(currentBlock)) {
              response.balances[currentBlock] = { ...trackedAddressBalances }
              if (atBlocks[atBlocks.length - 1] === currentBlock) {
                draining = true
                if (progressInterval !== undefined) {
                  clearInterval(progressInterval)
                }
                await syncClient.shutdown()
                return resolve(response)
              }
            }
          }
          requestNext()
        }
      },
      reject,
      () => {},
      {
        connection: options.ogmiosConnectionConfig
      })
      response.metadata.cardano.intersection = await syncClient.startSync(['origin'])
    } catch (error) {
      console.error(error)
      return reject(error)
    }
  })
}
