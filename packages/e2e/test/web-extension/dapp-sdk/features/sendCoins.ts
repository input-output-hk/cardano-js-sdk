/* eslint-disable @typescript-eslint/no-explicit-any, sonarjs/no-nested-template-literals */
import { Cardano } from '@cardano-sdk/core';
import { EMPTY, catchError, take, tap } from 'rxjs';
import { Logger } from '@cardano-sdk/util-dev';
import { inspectAndSignTx } from '../utils';
import type { ObservableWallet } from '@cardano-sdk/wallet';

type DataToSend = {
  receiverAddress: string;
  adaAmount: string;
  assetAmount?: string;
  assetPolicyId?: string;
  assetName?: string;
};

const buildAndSendTxWithAssets = async ({
  connectedWallet,
  logger,
  dataToSend
}: {
  connectedWallet: ObservableWallet;
  logger: Logger;
  dataToSend: DataToSend;
}) => {
  const addressAssetsElement = document.querySelector('#info-send')!;
  const transactionInfoElement = document.querySelector('#info-several-assets-tokens-transaction')!;
  const { receiverAddress, adaAmount, assetAmount, assetPolicyId, assetName } = dataToSend;

  connectedWallet.balance.utxo.available$
    .pipe(
      take(1),
      tap(async (availableBalance) => {
        if (!availableBalance.assets || availableBalance.assets?.size === 0) {
          throw new Error('Your wallet has no assets');
        }

        const assetId = Cardano.AssetId.fromParts(assetPolicyId! as Cardano.PolicyId, assetName! as Cardano.AssetName);
        const selectedAsset = [...availableBalance.assets].find(([key]) => key === assetId);

        const selectedAssetMap = new Map();
        if (!selectedAsset) {
          throw new Error(`Asset with ID ${assetId} doesn't exist`);
        } else {
          selectedAssetMap.set(assetId, BigInt(assetAmount!));
        }
        const txBuilder = connectedWallet.createTxBuilder();
        const output = await txBuilder
          .buildOutput()
          .address(receiverAddress as Cardano.PaymentAddress)
          .coin(BigInt(adaAmount))
          .assets(selectedAssetMap)
          .build();
        const builtTx = txBuilder.addOutput(output).build();
        await inspectAndSignTx({ builtTx, connectedWallet, textElement: transactionInfoElement });
        addressAssetsElement.textContent += `Assets and quantity: ${[...selectedAssetMap]
          .map(([key, value]) => `- ${key} : ${value}`)
          .join('\r\n')}`;
      }),
      catchError((error) => {
        logger.error('Error fetching assets:', error);
        return EMPTY;
      })
    )
    .subscribe();
};

export const sendCoins = async ({
  connectedWallet,
  logger,
  dataToSend
}: {
  connectedWallet: ObservableWallet;
  logger: Logger;
  dataToSend: DataToSend;
}) => {
  const sendInfoElement = document.querySelector('#info-send')!;
  const { receiverAddress, adaAmount, assetAmount, assetPolicyId, assetName } = dataToSend;

  const builder = connectedWallet.createTxBuilder();

  if (assetAmount && assetPolicyId && assetName) {
    await buildAndSendTxWithAssets({
      connectedWallet,
      dataToSend,
      logger
    });
  } else {
    const txOut = await builder
      .buildOutput()
      .address(receiverAddress as Cardano.PaymentAddress)
      .coin(BigInt(adaAmount))
      .build();
    const builtTx = builder.addOutput(txOut).build();
    await inspectAndSignTx({ builtTx, connectedWallet, textElement: sendInfoElement });
  }
};
