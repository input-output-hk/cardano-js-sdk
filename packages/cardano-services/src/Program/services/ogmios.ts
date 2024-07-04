/* eslint-disable promise/no-nesting */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { DnsResolver } from '../utils';
import { Logger } from 'ts-log';
import { MissingCardanoNodeOption } from '../errors';
import { OgmiosCardanoNode, OgmiosObservableCardanoNode, urlToConnectionConfig } from '@cardano-sdk/ogmios';
import { OgmiosOptionDescriptions, OgmiosProgramOptions } from '../options/ogmios';
import { defer, from, of } from 'rxjs';

/**
 * Creates an ObservableOgmiosCardanoNode instance :
 * - use passed srv service name in order to resolve the port
 * - all other operations are bind to pool object without modifications
 *
 * @returns ObservableOgmiosCardanoNode instance
 */
export const ogmiosObservableCardanoNodeWithDiscovery = (
  dnsResolver: DnsResolver,
  logger: Logger,
  serviceName: string
): OgmiosObservableCardanoNode =>
  new OgmiosObservableCardanoNode(
    {
      connectionConfig$: defer(() => from(dnsResolver(serviceName).then(({ name, port }) => ({ host: name, port }))))
    },
    { logger }
  );

export const getOgmiosObservableCardanoNode = (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: OgmiosProgramOptions
): OgmiosObservableCardanoNode => {
  if (options?.ogmiosSrvServiceName)
    return ogmiosObservableCardanoNodeWithDiscovery(dnsResolver, logger, options.ogmiosSrvServiceName);
  if (options?.ogmiosUrl)
    return new OgmiosObservableCardanoNode(
      { connectionConfig$: of(urlToConnectionConfig(options.ogmiosUrl)) },
      { logger }
    );
  throw new MissingCardanoNodeOption([OgmiosOptionDescriptions.Url, OgmiosOptionDescriptions.SrvServiceName]);
};

export const getOgmiosCardanoNode = async (
  dnsResolver: DnsResolver,
  logger: Logger,
  options?: OgmiosProgramOptions
): Promise<OgmiosCardanoNode> =>
  new OgmiosCardanoNode(getOgmiosObservableCardanoNode(dnsResolver, logger, options), logger);
