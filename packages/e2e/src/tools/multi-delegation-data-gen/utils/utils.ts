/* eslint-disable no-console, max-statements, max-params, @typescript-eslint/no-floating-promises */
import { Cardano } from '@cardano-sdk/core';
import { KeyPurpose, util } from '@cardano-sdk/key-management';
import { logger } from '@cardano-sdk/util-dev';

import { BaseWallet } from '@cardano-sdk/wallet';
import { Files, Paths } from './files';
import {
  KeyAgentFactoryProps,
  MINUTE,
  firstValueFromTimed,
  getEnv,
  getWallet,
  submitAndConfirm,
  walletReady,
  walletVariables
} from '../../../';
import { Observable, filter, firstValueFrom, map } from 'rxjs';
import { TaskResult, TerminalProgressMonitor } from './terminal-progress-monitor';
import { ValueTransferConfig, configLoader } from './config';
import chalk from 'chalk';

/**
 * Gets a list of the available pool.
 *
 * @param wallet The wallet to get the pools from.
 * @param count The requested number of pools.
 */
const getPoolIds = async (wallet: BaseWallet, count: number): Promise<Cardano.StakePool[]> => {
  const activePools = await wallet.stakePoolProvider.queryStakePools({
    filters: { status: [Cardano.StakePoolStatus.Active] },
    pagination: { limit: count, startAt: 0 }
  });

  return Array.from({ length: count }).map((_, index) => activePools.pageResults[index]);
};

/**
 * Awaits for rewardAccounts$ to be registered, unregistered, as defined in states.
 *
 * @param rewardAccounts$ The reward accounts observable.
 * @param statuses the statuses we are waiting for.
 * @param timeout the amount of time we will wait for the status to change.
 */
export const rewardAccountStatuses = async (
  rewardAccounts$: Observable<Cardano.RewardAccountInfo[]>,
  statuses: Cardano.StakeCredentialStatus[],
  timeout = MINUTE
) =>
  firstValueFromTimed(
    rewardAccounts$.pipe(
      map((accts) => accts.map(({ credentialStatus }) => credentialStatus)),
      filter((statusArr) => statusArr.every((s) => statuses.includes(s)))
    ),
    `Timeout waiting for all reward accounts stake keys to be one of ${statuses.join('|')}`,
    timeout
  );

const env = getEnv(walletVariables);

/**
 * Formats a given number with the given number of decimals.
 *
 * @param num The number to be formatted.
 * @param decimals The number of decimals.
 */
const format = (num: number, decimals: number) =>
  num.toLocaleString('en-US', {
    maximumFractionDigits: decimals,
    minimumFractionDigits: decimals
  });

/**
 * Loads the application configuration.
 *
 * @param monitor The progress monitor
 */
export const loadConfiguration = async (monitor: TerminalProgressMonitor) => {
  const configFilePath = process.argv[2];

  monitor.startTask(`Loading config file from ${chalk.green(configFilePath)}.`);

  configLoader.loadFile(configFilePath);
  configLoader.validate({ allowed: 'strict' });

  monitor.endTask(`Configuration loaded from ${chalk.green(configFilePath)}`, TaskResult.Success);

  return configLoader.getProperties();
};

/**
 * Waits until the funding wallet is ready.
 *
 * @param monitor The progress monitor
 */
export const waitForFundingWallet = async (monitor: TerminalProgressMonitor): Promise<BaseWallet> => {
  monitor.startTask('Waiting for funding wallet to be ready.');

  const fundingWallet = (
    await getWallet({
      env,
      idx: 0,
      logger,
      name: 'Funding wallet',
      polling: { interval: 500 },
      purpose: KeyPurpose.STANDARD
    })
  ).wallet;

  await walletReady(fundingWallet);

  monitor.endTask('Funding wallet ready', TaskResult.Success);

  return fundingWallet;
};

/**
 * Creates a new delegation wallet.
 *
 * @param monitor The progress monitor.
 */
export const createDelegationWallet = async (monitor: TerminalProgressMonitor) => {
  monitor.startTask('Creating a random set of mnemonics for a brand-new wallet.');

  const mnemonics = util.generateMnemonicWords();

  monitor.endTask(`Mnemonics generated: [${chalk.green!(mnemonics.join(', '))}]`, TaskResult.Success);

  const customKeyParams: KeyAgentFactoryProps = {
    accountIndex: 0,
    chainId: env.KEY_MANAGEMENT_PARAMS.chainId,
    mnemonic: mnemonics.join(' '),
    passphrase: 'some_passphrase'
  };

  return (
    await getWallet({
      customKeyParams,
      env,
      idx: 0,
      logger,
      name: 'Delegation Wallet',
      polling: { interval: 500 },
      purpose: KeyPurpose.STANDARD
    })
  ).wallet;
};

/**
 * Transfers the starting funds from the funding wallet to the delegation wallet.
 *
 * @param fundingWallet The funding wallet contains the original funds, and serves as a faucet.
 * @param delegationWallet The delegation wallet is our test wallet.
 * @param startingFunds The initial funds to be transferred.
 * @param monitor The progress monitor.
 */
export const transferStartingFunds = async (
  fundingWallet: BaseWallet,
  delegationWallet: BaseWallet,
  startingFunds: number,
  monitor: TerminalProgressMonitor
) => {
  monitor.startTask(`Transferring ${startingFunds} to delegation wallet.`);

  const delegationWalletAddress = await firstValueFrom(delegationWallet.addresses$);

  const txBuilder = fundingWallet.createTxBuilder();
  txBuilder.addOutput(
    txBuilder.buildOutput().address(delegationWalletAddress[0].address).coin(BigInt(startingFunds)).toTxOut()
  );

  const { tx: signedTx } = await txBuilder.build().sign();

  await submitAndConfirm(fundingWallet, signedTx);

  monitor.endTask('Funds transferred', TaskResult.Success);
};

/**
 * Distribute the stake among different addresses.
 *
 * @param delegationWallet The delegation wallets.
 * @param stakeDistribution The stake distribution to be followed.
 * @param monitor The progress monitor.
 */
export const distributeStake = async (
  delegationWallet: BaseWallet,
  stakeDistribution: Array<number>,
  monitor: TerminalProgressMonitor
): Promise<Cardano.Cip17DelegationPortfolio> => {
  const pools = await getPoolIds(delegationWallet, stakeDistribution.length);

  const portfolio: Cardano.Cip17DelegationPortfolio = {
    name: 'Portfolio',
    pools: pools.map((pool, index) => ({ id: pool.hexId, weight: stakeDistribution[index] }))
  };

  logger.debug('Delegating portfolio', portfolio);

  const { tx } = await delegationWallet.createTxBuilder().delegatePortfolio(portfolio).build().sign();
  await submitAndConfirm(delegationWallet, tx);

  monitor.endTask('Funds distributed', TaskResult.Success);

  return portfolio;
};

/**
 * Logs in the terminal and persist the current state of the wallet.
 *
 * @param delegationWallet The delegation wallet.
 * @param iteration The current test iteration.
 * @param outputPath The output path were to persist the state.
 * @param monitor The progress monitor.
 */
export const logState = async (
  delegationWallet: BaseWallet,
  iteration: number,
  outputPath: string,
  monitor: TerminalProgressMonitor
) => {
  const paddedIter = `00000${iteration}`.slice(-4);
  const delegationDistribution = await firstValueFrom(delegationWallet.delegation.distribution$);
  const { coins: totalCoins } = await firstValueFrom(delegationWallet.balance.utxo.total$);
  const utxos = await firstValueFrom(delegationWallet.utxo.total$);

  monitor.logInfo(
    `${paddedIter} - Total coins: ${totalCoins} - Distribution: [${[...delegationDistribution.values()]
      .map(
        (delegatedStake) =>
          // eslint-disable-next-line sonarjs/no-nested-template-literals
          `${delegatedStake.stake.toString()}(${chalk.green(`${format(delegatedStake.percentage * 100, 2)}%`)})`
      )
      .join(', ')}]`
  );

  const distributionCSV = Files.combine([outputPath, Paths.StakeDistribution]);
  const utxoDirectory = Files.combine([outputPath, Paths.WalletUtxos]);
  const utxosFile = Files.combine([utxoDirectory, `${paddedIter}.json`]);

  Files.createFolder(outputPath);
  Files.createFolder(utxoDirectory);

  const csvEntries = [totalCoins, [...delegationDistribution.values()].map((delegatedStake) => delegatedStake.stake)];

  Files.writeFile(distributionCSV, `${paddedIter},${csvEntries.join(',')}\n`, true);
  Files.writeFile(
    utxosFile,
    JSON.stringify(utxos, (_, v) => (typeof v === 'bigint' ? v.toString() : v), 2)
  );
};

/**
 * Gets a random number between two intervals.
 *
 * @param min The lower bound value of te interval (inclusive).
 * @param max The upper bound value of te interval (inclusive).
 */
export const randomFromInterval = (min: number, max: number) => Math.floor(Math.random() * (max - min + 1) + min);

/** Creates a folder name using a timestamp. */
export const getOutputPathName = () =>
  new Date().toISOString().replace(/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}).*/, '$1_$2_$3_$4_$5_$6');

/**
 * Transfer value from one wallet to another following the given value transfer configuration.
 *
 * @param wallet The source wallet.
 * @param targetAddress The target wallet.
 * @param config The value transfer configuration.
 * @param currentIteration the current iteration.
 */
const transferValue = async (
  wallet: BaseWallet,
  targetAddress: Cardano.PaymentAddress,
  config: ValueTransferConfig,
  currentIteration: number
) => {
  const outputCount = randomFromInterval(config.count.min, config.count.max);
  if (outputCount === 0 || config.period === 0 || currentIteration % config.period !== 0) return;

  const txBuilder = wallet.createTxBuilder();

  for (let i = 0; i < outputCount; ++i) {
    const amountToBeGenerated = randomFromInterval(config.amount.min, config.amount.max);
    txBuilder.addOutput(txBuilder.buildOutput().address(targetAddress).coin(BigInt(amountToBeGenerated)).toTxOut());
  }

  const { tx: signedTx } = await txBuilder.build().sign();

  await submitAndConfirm(wallet, signedTx);
};

/**
 * Generate and submit transaction following the given input and output configuration.
 *
 * This function will create on transaction transferring funds from the funding wallet to the
 * delegation wallet (inputs), and one transaction transferring funds from the delegation wallet
 * to the funding wallet (outputs).
 *
 * @param fundingWallet The funding wallet contains the original funds, and serves as a faucet.
 * @param delegationWallet The delegation wallet is our test wallet.
 * @param inputsConfig The configuration parameters for the input generation.
 * @param outputsConfig The configuration parameters for the output generation.
 * @param iteration Tue current iteration we are in.
 * @param monitor The progress monitor.
 */
export const sendTransactions = async (
  fundingWallet: BaseWallet,
  delegationWallet: BaseWallet,
  inputsConfig: ValueTransferConfig,
  outputsConfig: ValueTransferConfig,
  iteration: number,
  monitor: TerminalProgressMonitor
) => {
  const inputAddress = (await firstValueFrom(delegationWallet.addresses$))[0].address;
  const outputAddress = (await firstValueFrom(fundingWallet.addresses$))[0].address;
  const paddedIter = `00000${iteration}`.slice(-4);

  monitor.startTask(`${paddedIter} - Generating incoming and outgoing transactions`);

  await transferValue(fundingWallet, inputAddress, inputsConfig, iteration);
  await transferValue(delegationWallet, outputAddress, outputsConfig, iteration);

  monitor.endTask('', TaskResult.None);
};
