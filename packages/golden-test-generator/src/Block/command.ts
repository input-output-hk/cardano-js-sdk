import chalk from 'chalk'
import cliProgress from 'cli-progress'
import { createCommand } from 'commander'
import { ensureDir, writeJson } from 'fs-extra'
import path from 'path'
import { getBlocks } from './getBlocks'

export function blocksCommand () {
  return createCommand('blocks')
    .description('Dump the requested blocks in their raw structure')
    .argument(
      '[blockHeights]', 'Comma-separated list of blocks by number',
      (blockHeights) => blockHeights.split(',').map(blockHeight => parseInt(blockHeight))
    )
    .requiredOption('--out-dir [outDir]', 'File path to write results to')
    .action(async (blockHeights: number[], { outDir }) => {
      const sortedblockHeights = blockHeights.sort((a: number, b: number) => a - b)
      const lastblockHeight = sortedblockHeights[sortedblockHeights.length - 1]
      const fileName = path.join(outDir, `blocks-${sortedblockHeights.join('-')}.json`)

      const progress = new cliProgress.SingleBar({
        format: `Syncing from genesis to block ${lastblockHeight} | ${chalk.blue('{bar}')} | {percentage}% || {value}/{total} Blocks`,
        barCompleteChar: '\u2588',
        barIncompleteChar: '\u2591',
        hideCursor: true
      })
      await ensureDir(outDir)
      progress.start(lastblockHeight, 0)
      const balances = await getBlocks(sortedblockHeights, {
        progress: {
          callback: (blockHeight) => progress.update(blockHeight),
          interval: 2000
        }
      })
      progress.stop()
      console.log(`Writing ${fileName}`)
      await writeJson(
        fileName,
        balances,
        { spaces: 2 }
      )
      process.exit(0)
    })
}
