import {
  createChainSyncClient,
  isAllegraBlock,
  isShelleyBlock,
  isMaryBlock,
  Schema
} from '@cardano-ogmios/client'
import {
  isByronEpochBoundaryBlock,
  isByronStandardBlock
} from '../util'

export type Response = {
  [blockHeight: string]: Schema.Block
}

export async function getBlocks (
  blockHeights: number[],
  options?: {
    progress?: {
      callback: (slot: number) => void
      interval: number
    }
  }
): Promise<Response> {
  const response = new Map<number, Schema.Block>()
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
          if (isByronEpochBoundaryBlock(block)) return
          let b: Schema.StandardBlock
            | Schema.BlockShelley
            | Schema.BlockAllegra
            | Schema.BlockMary
          if (isByronStandardBlock(block)) {
            b = block.byron as Schema.StandardBlock
          } else if (isShelleyBlock(block)) {
            b = block.shelley as Schema.BlockShelley
          } else if (isAllegraBlock(block)) {
            b = block.allegra as Schema.BlockAllegra
          } else if (isMaryBlock(block)) {
            b = block.mary as Schema.BlockMary
          }
          if (b !== undefined) {
            currentBlock = b.header.blockHeight
            if (blockHeights.includes(currentBlock)) {
              response.set(currentBlock, block)
              if (blockHeights[blockHeights.length - 1] === currentBlock) {
                draining = true
                if (progressInterval !== undefined) {
                  clearInterval(progressInterval)
                }
                await syncClient.shutdown()
                return resolve(Object.fromEntries(response))
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
