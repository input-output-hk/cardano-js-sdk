/* eslint-disable no-console, max-statements, @typescript-eslint/no-floating-promises, unicorn/no-process-exit */
import {
  Files,
  Paths,
  TaskResult,
  TerminalProgressMonitor,
  createDelegationWallet,
  delegateToMultiplePools,
  distributeStake,
  generateStakeAddresses,
  getOutputPathName,
  loadConfiguration,
  logState,
  rewardAccountStatuses,
  sendTransactions,
  transferStartingFunds,
  waitForFundingWallet
} from './utils';

import { Cardano } from '@cardano-sdk/core';
import { PersonalWallet } from '@cardano-sdk/wallet';
import { walletReady } from '../../';
import chalk from 'chalk';

const monitor = new TerminalProgressMonitor();

/**
 * This script creates a new wallet, delegate to multiple pools, and execute transactions
 * over a period of time. The state of the wallet (UTXO set) and the stake distribution at each
 * iteration is stored.
 */
(async () => {
  if (process.argv.length < 3) {
    console.log(
      'USAGE: yarn workspace @cardano-sdk/e2e multi-delegation-data-gen [JSON_CONFIG_FILE_PATH] [SCRIPT_WORKING_DIRECTORY]'
    );
    return;
  }

  let exitCode = 0;
  let fundingWallet: PersonalWallet | undefined;

  try {
    const config = await loadConfiguration(monitor);

    if (process.argv.length > 3) process.chdir(process.argv[3]);

    const outputPath = getOutputPathName();

    // Initialize the CSV file with its header.
    const stakeKeysToUse = config.stakeDistribution.map((_, index) => `Stake ${index}`);
    Files.writeFile(
      Files.combine([outputPath, Paths.StakeDistribution]),
      `Iteration, Total, ${stakeKeysToUse.join(',')}\n`,
      true
    );

    monitor.logInfo(`Output directory: ${chalk.green!(Files.combine([process.cwd(), outputPath]))}`);

    fundingWallet = await waitForFundingWallet(monitor);

    const delegationWallet = await createDelegationWallet(monitor);

    await transferStartingFunds(fundingWallet, delegationWallet, config.startingFunds, monitor);

    monitor.startTask('Waiting for delegation wallet to be ready.');

    await walletReady(delegationWallet);

    monitor.endTask('Delegation wallet ready.', TaskResult.Success);

    const stakeAddresses = await generateStakeAddresses(delegationWallet, config.stakeDistribution.length, monitor);

    await delegateToMultiplePools(delegationWallet, stakeAddresses, monitor);

    await distributeStake(delegationWallet, config.startingFunds, config.stakeDistribution, stakeAddresses, monitor);

    monitor.startTask('Waiting for delegation to be updated on the wallet.');
    await rewardAccountStatuses(delegationWallet.delegation.rewardAccounts$, [
      Cardano.StakeKeyStatus.Registering,
      Cardano.StakeKeyStatus.Registered
    ]);
    monitor.endTask('Delegation updated.', TaskResult.Success);

    monitor.logInfo('Setup phase ended. Starting interactions...');

    // Initial setup done, log starting state.
    await logState(delegationWallet, 0, outputPath, monitor);

    // Runs indefinitely if iterations is set to 0.
    for (let i = 1; config.iterations === 0 || i < config.iterations; ++i) {
      await sendTransactions(fundingWallet, delegationWallet, config.utxoIn, config.utxoOut, i, monitor);
      await logState(delegationWallet, i, outputPath, monitor);
    }

    monitor.logSuccess('Data generation complete.');
  } catch (error) {
    exitCode = -1;
    const message = error instanceof Error ? error.message : JSON.stringify(error);

    if (monitor.isTrackingTask()) {
      monitor.endTask(message, TaskResult.Fail);
    } else {
      monitor.logFailure(message);
    }
  } finally {
    fundingWallet?.shutdown();
    process.exit(exitCode);
  }
})();
