import { CommonProgramOptions, OgmiosProgramOptions, RabbitMqProgramOptions } from '../options';
import { Logger } from 'ts-log';
import { TxSubmitWorkerConfig } from '../../TxSubmit';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { getOgmiosTxSubmitProvider, getRunningTxSubmitWorker } from '../services';

export const TX_WORKER_API_URL_DEFAULT = new URL('http://localhost:3001');
export const PARALLEL_MODE_DEFAULT = false;
export const PARALLEL_TXS_DEFAULT = 3;
export const POLLING_CYCLE_DEFAULT = 500;

export enum TxWorkerOptionDescriptions {
  Parallel = 'Parallel mode',
  ParallelTxs = 'Parallel transactions',
  PollingCycle = 'Polling cycle'
}

export type TxWorkerOptions = CommonProgramOptions &
  OgmiosProgramOptions &
  RabbitMqProgramOptions &
  Pick<TxSubmitWorkerConfig, 'parallel' | 'parallelTxs' | 'pollingCycle'>;

export interface TxWorkerArgs {
  options: TxWorkerOptions;
}

export const loadAndStartTxWorker = async (args: TxWorkerArgs, logger?: Logger) => {
  const { loggerMinSeverity, serviceDiscoveryBackoffFactor, serviceDiscoveryTimeout } = args.options;

  if (!logger) logger = createLogger({ level: loggerMinSeverity, name: 'tx-worker' });

  const dnsResolver = createDnsResolver(
    {
      factor: serviceDiscoveryBackoffFactor,
      maxRetryTime: serviceDiscoveryTimeout
    },
    logger
  );
  const txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, logger, args.options);
  return await getRunningTxSubmitWorker(dnsResolver, txSubmitProvider, logger, args.options);
};
