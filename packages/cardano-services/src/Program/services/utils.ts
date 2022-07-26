/* eslint-disable @typescript-eslint/no-explicit-any */

import { Logger } from 'ts-log';
import { Ogmios } from '@cardano-sdk/ogmios';
import dns, { SrvRecord } from 'dns';
import pRetry, { FailedAttemptError } from 'p-retry';

export const SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT = 1.1;
export const SERVICE_DISCOVERY_TIMEOUT_DEFAULT = 60 * 1000;
export const DNS_SRV_CACHE_KEY = 'DNS_SRV_Record';

export type RetryBackoffConfig = {
  factor?: number;
  maxRetryTime?: number;
};

export const onFailedAttemptFor =
  (serviceName: string, logger: Logger) =>
  async ({ attemptNumber, message, retriesLeft }: FailedAttemptError) => {
    const nextAction = retriesLeft > 0 ? 'retrying...' : 'exiting';
    logger.trace(message);
    logger.debug(
      `Establishing connection to ${serviceName}: Attempt ${attemptNumber} of ${
        attemptNumber + retriesLeft
      }, ${nextAction}`
    );
    if (retriesLeft === 0) {
      logger.error(message);
      // Invokes onDeath() callback within cardano-services entrypoints,
      // following by server.shutdown() and process.exit(1)
      process.kill(process.pid, 'SIGTERM');
    }
  };

// Select the first random record from the DNS server resolved list
export const resolveSrvRecord = async (serviceName: string): Promise<SrvRecord> => {
  const [srvRecord] = await dns.promises.resolveSrv(serviceName);
  return srvRecord;
};

export const createDnsResolver = (config: RetryBackoffConfig, logger: Logger) => async (serviceName: string) =>
  await pRetry(async () => await resolveSrvRecord(serviceName), {
    factor: config.factor,
    maxRetryTime: config.maxRetryTime,
    onFailedAttempt: onFailedAttemptFor(serviceName, logger)
  });

export const connectionErrorCodes = ['ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET'];

export const isOgmiosConnectionError = (error: any) => {
  if (
    (error?.code && connectionErrorCodes.includes(error.code)) ||
    (error?.message && connectionErrorCodes.some((err) => error.message.includes(err))) ||
    error instanceof Ogmios.WebSocketClosed
  ) {
    return true;
  }
  return false;
};

export type DnsResolver = ReturnType<typeof createDnsResolver>;
