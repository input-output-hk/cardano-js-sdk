import { CommonProgramOptions } from './Options';
import { Logger } from 'ts-log';
import { TxSubmitWorkerConfig } from '../TxSubmit';
import { createDnsResolver } from './utils';
import { createLogger } from 'bunyan';
import { getOgmiosTxSubmitProvider, getRunningTxSubmitWorker } from './services';

export type TxWorkerOptions = CommonProgramOptions &
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
