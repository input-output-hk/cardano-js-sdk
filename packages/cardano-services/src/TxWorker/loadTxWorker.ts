import { CommonOptionDescriptions, CommonProgramOptions } from '../ProgramsCommon';
import { MissingProgramOption, ServiceNames } from '../Program';
import { TxSubmitWorker, TxSubmitWorkerConfig } from '@cardano-sdk/rabbitmq';
import { createLogger } from 'bunyan';
import { ogmiosTxSubmitProvider, urlToConnectionConfig } from '@cardano-sdk/ogmios';

export type TxWorkerOptions = CommonProgramOptions &
  Pick<TxSubmitWorkerConfig, 'parallel' | 'parallelTxs' | 'pollingCycle'>;

export interface TxWorkerArgs {
  options: TxWorkerOptions;
}

export const loadTxWorker = async (args: TxWorkerArgs) => {
  const { loggerMinSeverity, ogmiosUrl, rabbitmqUrl } = args.options;
  const txSubmitProvider = ogmiosTxSubmitProvider(urlToConnectionConfig(ogmiosUrl));
  const logger = createLogger({ level: loggerMinSeverity, name: 'tx-worker' });

  // Ensure rabbitmqUrl is not undefined
  if (!rabbitmqUrl) throw new MissingProgramOption(ServiceNames.TxSubmit, CommonOptionDescriptions.RabbitMQUrl);

  return new TxSubmitWorker({ ...args.options, rabbitmqUrl }, { logger, txSubmitProvider });
};
