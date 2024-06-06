/* eslint-disable jsdoc/require-returns-type */
import { Cardano } from '@cardano-sdk/core';
import { genesisParameters, ledgerTip, protocolParameters } from './mockData.js';
import { networkInfo } from './mockNetworkInfoProvider.js';
import delay from 'delay';

export const protocolParameters2 = {
  ...protocolParameters,
  maxCollateralInputs: protocolParameters.maxCollateralInputs + 1
};

export const genesisParameters2 = {
  ...genesisParameters,
  maxLovelaceSupply: genesisParameters.maxLovelaceSupply + 1n
};

export const ledgerTip2 = {
  ...ledgerTip,
  blockNo: Cardano.BlockNo(ledgerTip.blockNo + 1)
};

/**
 * A different provider stub for testing, supports delay to simulate network requests.
 *
 * @returns NetworkInfoProvider that returns data that is slightly different to mockNetworkInfoProvider.
 */
export const mockNetworkInfoProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));

  return {
    eraSummaries: jest.fn().mockResolvedValue(networkInfo.network.eraSummaries),
    genesisParameters: delayedJestFn(genesisParameters2),
    healthCheck: delayedJestFn({ ok: true }),
    ledgerTip: delayedJestFn(ledgerTip2),
    lovelaceSupply: jest.fn().mockResolvedValue(networkInfo.lovelaceSupply),
    protocolParameters: delayedJestFn(protocolParameters2),
    stake: jest.fn().mockResolvedValue(networkInfo.stake)
  };
};
