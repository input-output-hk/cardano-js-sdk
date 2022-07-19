import { CommonProgramOptions } from '../ProgramsCommon';
import { Logger } from 'ts-log';
import { TxSubmitWorkerConfig } from '@cardano-sdk/rabbitmq';
import { createDnsResolver, getOgmiosTxSubmitProvider } from '../Program';
import { createLogger } from 'bunyan';
import { getRunningTxSubmitWorker } from './utils';

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
