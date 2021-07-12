import {
  createChainSyncClient,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema, ConnectionConfig
} from '@cardano-ogmios/client'
import { isByronStandardBlock } from '../util'

export type Response = {
  [blockHeight: string]: {
    [address: string]: Schema.Value
  }
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
): Promise<Response> {
  const balances = Object.fromEntries(
    addresses.map(address => [address, { coins: 0, assets: undefined }])
  )
  const response: Response = {}
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
                const { address, value } = output
                if (addresses.includes(address)) {
                  const { assets, coins } = balances[address]
                  const newAssetsObj: { [asset: string]: number } = {}
                  if (value.assets !== undefined) {
                    Object.entries(value.assets).forEach(([asset, qty]) => {
                      newAssetsObj[asset] = assets[asset] !== undefined ? assets[asset] + qty : qty
                    })
                  }
                  balances[address] = {
                    coins: coins + output.value.coins,
                    assets: newAssetsObj
                  }
                }
              }
            }
            if (atBlocks.includes(currentBlock)) {
              response[currentBlock] = balances
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
      await syncClient.startSync(['origin'])
    } catch (error) {
      console.error(error)
      return reject(error)
    }
  })
}
