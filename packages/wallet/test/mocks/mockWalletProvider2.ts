/* eslint-disable jsdoc/require-returns-type */
import { currentEpoch, genesisParameters, ledgerTip, protocolParameters } from './mockData';
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

export const currentEpochNo2 = currentEpoch.number + 1;

export const delegate2 = 'pool167u07rzwu6dr40hx2pr4vh592vxp4zen9ct2p3h84wzqzv6fkgv';

/**
 * A different provider stub for testing, supports delay to simulate network requests.
 *
 * @returns WalletProvider that returns data that is slightly different to mockWalletProvider.
 */
export const mockWalletProvider2 = (delayMs: number) => {
  const delayedJestFn = <T>(resolvedValue: T) =>
    jest.fn().mockImplementation(() => delay(delayMs).then(() => resolvedValue));

  return {
    currentWalletProtocolParameters: delayedJestFn(protocolParameters2),
    genesisParameters: delayedJestFn(genesisParameters2),
    ledgerTip: delayedJestFn(ledgerTip2)
  };
};
