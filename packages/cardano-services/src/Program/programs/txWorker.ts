import { CommonProgramOptions, OgmiosProgramOptions, RabbitMqProgramOptions } from '../options';
import { Logger } from 'ts-log';
import { NodeTxSubmitProvider, TxSubmitWorkerConfig } from '../../TxSubmit';
import { createDnsResolver } from '../utils';
import { createLogger } from 'bunyan';
import { getOgmiosObservableCardanoNode, getRunningTxSubmitWorker } from '../services';

export const TX_WORKER_API_URL_DEFAULT = new URL('http://localhost:3001');
export const PARALLEL_MODE_DEFAULT = false;
export const PARALLEL_TXS_DEFAULT = 3;
export const POLLING_CYCLE_DEFAULT = 500;

export enum TxWorkerOptionDescriptions {
  Parallel = 'Parallel mode',
  ParallelTxs = 'Parallel transactions',
  PollingCycle = 'Polling cycle'
}

export type TxWorkerArgs = CommonProgramOptions &
  OgmiosProgramOptions &
  RabbitMqProgramOptions &
  Pick<TxSubmitWorkerConfig, 'parallel' | 'parallelTxs' | 'pollingCycle'>;

export const loadAndStartTxWorker = async (args: TxWorkerArgs, logger?: Logger) => {
  const { loggerMinSeverity, serviceDiscoveryBackoffFactor, serviceDiscoveryTimeout } = args;

  if (!logger) logger = createLogger({ level: loggerMinSeverity, name: 'tx-worker' });

  const dnsResolver = createDnsResolver(
    {
      factor: serviceDiscoveryBackoffFactor,
      maxRetryTime: serviceDiscoveryTimeout
    },
    logger
  );
  const txSubmitProvider = new NodeTxSubmitProvider({
    cardanoNode: getOgmiosObservableCardanoNode(dnsResolver, logger, args),
    // TODO: worker should utilize a handle provider
    // handleProvider: await getHandleProvider(),
    logger
  });
  return await getRunningTxSubmitWorker(dnsResolver, txSubmitProvider, logger, args);
};
