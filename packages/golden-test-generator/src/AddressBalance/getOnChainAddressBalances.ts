import {
  createChainSyncClient,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema
} from '@cardano-ogmios/client'

export const isByronStandardBlock = (block: Schema.Block): block is { byron: Schema.StandardBlock } =>
  (block as { byron: Schema.StandardBlock }).byron?.header.slot !== undefined

export type Response = {
  [blockHeight: string]: {
    [address: string]: number
  }
}

export async function getOnChainAddressBalances (
  addresses: string[],
  atBlocks: number[],
  options?: {
    progress?: {
      callback: (slot: number) => void
      interval: number
    }
  }
): Promise<Response> {
  const balances = new Map(addresses.map(address => [address, 0]))
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
    // Required to ensure existing messages in the pipe are not processed after the completion condition is met
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
                const { address } = output
                if (addresses.includes(address)) {
                  const currentBalance = balances.get(address)
                  balances.set(address, currentBalance + output.value.coins)
                }
              }
            }
            if (atBlocks.includes(currentBlock)) {
              response[currentBlock] = Object.fromEntries(balances)
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
      () => {}
      )
      await syncClient.startSync(['origin'])
    } catch (error) {
      console.error(error)
      return reject(error)
    }
  })
}
