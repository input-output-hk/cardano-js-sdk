import { Command, Option } from 'commander';
import { Ogmios } from '@cardano-sdk/ogmios';
import { URL } from 'url';

const OGMIOS_URL_DEFAULT = (() => {
  const connection = Ogmios.createConnectionObject();
  return connection.address.webSocket;
})();

export enum OgmiosOptionDescriptions {
  SrvServiceName = 'Ogmios SRV service name',
  Url = 'Ogmios URL'
}

export interface OgmiosProgramOptions {
  ogmiosUrl?: URL;
  ogmiosSrvServiceName?: string;
}

export const withOgmiosOptions = (command: Command) =>
  command
    .addOption(
      new Option('--ogmios-srv-service-name <ogmiosSrvServiceName>', OgmiosOptionDescriptions.SrvServiceName).env(
        'OGMIOS_SRV_SERVICE_NAME'
      )
    )
    .addOption(
      new Option('--ogmios-url <ogmiosUrl>', OgmiosOptionDescriptions.Url)
        .env('OGMIOS_URL')
        .default(new URL(OGMIOS_URL_DEFAULT))
        .conflicts('ogmiosSrvServiceName')
        .argParser((url) => new URL(url))
    );
