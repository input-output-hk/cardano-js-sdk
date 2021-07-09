import chalk from 'chalk'
import cliProgress from 'cli-progress'
import { createCommand } from 'commander'
import { ensureDir, writeJson } from 'fs-extra'
import path from 'path'
import { getOnChainAddressBalances } from './getOnChainAddressBalances'

export function addressBalancesCommand () {
  return createCommand('address-balance')
    .description('Balance of addresses, determined by syncing the chain from genesis')
    .argument(
      '[addresses]', 'Comma-separated list of addresses',
      (addresses) => addresses.split(',')
    )
    .requiredOption(
      '--at-blocks [atBlocks]',
      'Balance of the addresses at block heights',
      (heights) => heights.split(',').map(height => parseInt(height))
    )
    .requiredOption('--out-dir [outDir]', 'File path to write results to')
    .action(async (addresses: string[], { atBlocks, outDir }) => {
      const atBlockHeights = atBlocks.sort((a: number, b: number) => a - b)
      const lastBlockHeight = atBlockHeights[atBlockHeights.length - 1]
      const fileName = path.join(outDir, `address-balances-${atBlockHeights.join('-')}.json`)

      const progress = new cliProgress.SingleBar({
        format: `Syncing from genesis to block ${lastBlockHeight} | ${chalk.blue('{bar}')} | {percentage}% || {value}/{total} Blocks`,
        barCompleteChar: '\u2588',
        barIncompleteChar: '\u2591',
        hideCursor: true
      })
      await ensureDir(outDir)
      progress.start(lastBlockHeight, 0)
      const balances = await getOnChainAddressBalances(addresses, atBlockHeights, {
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
