import { ProviderError, ProviderFailure, WalletProvider, util } from '@cardano-sdk/core';
import { WalletProviderFnProps } from './WalletProviderFnProps';

export const currentWalletProtocolParametersProvider =
  ({ getExactlyOneObject, sdk }: WalletProviderFnProps): WalletProvider['currentWalletProtocolParameters'] =>
  async () => {
    const { queryProtocolVersion } = await sdk.CurrentProtocolParameters();
    const { protocolParameters } = getExactlyOneObject(queryProtocolVersion, 'ProtocolVersion');
    if (protocolParameters.__typename !== 'ProtocolParametersAlonzo') {
      throw new ProviderError(ProviderFailure.NotFound, null, 'Expected Alonzo protocol parameters. Still syncing?');
    }
    return {
      coinsPerUtxoWord: protocolParameters.coinsPerUtxoWord,
      maxCollateralInputs: protocolParameters.maxCollateralInputs,
      maxTxSize: protocolParameters.maxTxSize,
      maxValueSize: protocolParameters.maxValueSize,
      minFeeCoefficient: protocolParameters.minFeeCoefficient,
      minFeeConstant: protocolParameters.minFeeConstant,
      minPoolCost: protocolParameters.minPoolCost,
      poolDeposit: protocolParameters.poolDeposit,
      protocolVersion: util.replaceNullsWithUndefineds(protocolParameters.protocolVersion),
      stakeKeyDeposit: protocolParameters.stakeKeyDeposit
    };
  };
