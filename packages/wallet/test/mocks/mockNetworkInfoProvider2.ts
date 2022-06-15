/* eslint-disable jsdoc/require-returns-type */
import { genesisParameters, ledgerTip, protocolParameters } from './mockData';
import { networkInfo } from './mockNetworkInfoProvider';
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
  blockNo: ledgerTip.blockNo + 1
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
    currentWalletProtocolParameters: delayedJestFn(protocolParameters2),
    genesisParameters: delayedJestFn(genesisParameters2),
    ledgerTip: delayedJestFn(ledgerTip2),
    networkInfo: jest.fn().mockResolvedValue(networkInfo)
  };
};
