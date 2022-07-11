import { CommonProgramOptions } from '../ProgramsCommon';
import { InMemoryCache } from '../InMemoryCache';
import { TxSubmitWorker, TxSubmitWorkerConfig } from '@cardano-sdk/rabbitmq';
import { createDnsResolver, getOgmiosTxSubmitProvider, getRabbitMqUrl } from '../Program';
import { createLogger } from 'bunyan';

export type TxWorkerOptions = CommonProgramOptions &
  Pick<TxSubmitWorkerConfig, 'parallel' | 'parallelTxs' | 'pollingCycle'>;

export interface TxWorkerArgs {
  options: TxWorkerOptions;
}

export const loadTxWorker = async (args: TxWorkerArgs) => {
  const { loggerMinSeverity, serviceDiscoveryBackoffFactor, serviceDiscoveryBackoffTimeout, cacheTtl } = args.options;
  const logger = createLogger({ level: loggerMinSeverity, name: 'tx-worker' });
  const cache = new InMemoryCache(cacheTtl);
  const dnsResolver = createDnsResolver(
    {
      factor: serviceDiscoveryBackoffFactor,
      maxRetryTime: serviceDiscoveryBackoffTimeout
    },
    cache,
    logger
  );
  const txSubmitProvider = await getOgmiosTxSubmitProvider(dnsResolver, args.options);
  const url = await getRabbitMqUrl(dnsResolver, args.options);

  return new TxSubmitWorker({ ...args.options, rabbitmqUrl: url }, { logger, txSubmitProvider });
};
