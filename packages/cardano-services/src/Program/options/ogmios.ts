import { Command } from 'commander';
import { Ogmios } from '@cardano-sdk/ogmios';
import { addOptions, newOption } from './util';
import { urlValidator } from '../../util/validators';

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
  addOptions(command, [
    newOption(
      '--ogmios-srv-service-name <ogmiosSrvServiceName>',
      OgmiosOptionDescriptions.SrvServiceName,
      'OGMIOS_SRV_SERVICE_NAME'
    ),
    newOption(
      '--ogmios-url <ogmiosUrl>',
      OgmiosOptionDescriptions.Url,
      'OGMIOS_URL',
      urlValidator(OgmiosOptionDescriptions.Url),
      new URL(OGMIOS_URL_DEFAULT)
    ).conflicts('ogmiosSrvServiceName')
  ]);
