import { ApiError, Bytes, Cbor, Paginate, TxSignError, WalletApi, handleMessages } from '@cardano-sdk/cip30';
import { CSL, Cardano, coreToCsl, cslToCore, parseCslAddress } from '@cardano-sdk/core';
import { KeyAgent } from './KeyManagement';
import { Logger, dummyLogger } from 'ts-log';
import { SingleAddressWallet } from '.';
import { cip30signData } from './KeyManagement/cip8';
import { firstValueFrom } from 'rxjs';

type Props = {
  keyAgent: KeyAgent;
  logger?: Logger;
};

export const createCip30WalletApiFromWallet = (wallet: SingleAddressWallet, props: Props): WalletApi => {
  const logger = props.logger || dummyLogger;
  return {
    getBalance: async (): Promise<Cbor> => {
      logger.debug('getting balance');
      try {
        const value = await firstValueFrom(wallet.balance.available$);
        return Buffer.from(coreToCsl.value(value).to_bytes()).toString('hex');
      } catch (error) {
        logger.error(error);
        throw error;
      }
    },
    getChangeAddress: async (): Promise<Cbor> => {
      logger.debug('getting changeAddress');
      try {
        const [{ address }] = await firstValueFrom(wallet.addresses$);
        const parsedAddress = parseCslAddress(address.toString());

        if (!address || !parsedAddress) {
          logger.error('could not get change address');
          throw new ApiError(500, 'could not get change address');
        } else {
          return Buffer.from(parsedAddress.to_bytes()).toString('hex');
        }
      } catch (error) {
        logger.error(error);
        throw new ApiError(500, error);
      }
    },
    getNetworkId: async (): Promise<number> => {
      logger.debug('getting networkId');
      return Promise.resolve(props.keyAgent.networkId);
    },
    getRewardAddresses: async (): Promise<Cbor[]> => {
      logger.debug('getting reward addresses');
      try {
        const [{ rewardAccount }] = await firstValueFrom(wallet.addresses$);
        const parsedAddress = parseCslAddress(rewardAccount.toString());

        if (!rewardAccount || !parsedAddress) {
          throw new ApiError(500, 'could not get reward address');
        } else {
          return [Buffer.from(parsedAddress.to_bytes()).toString('hex')];
        }
      } catch (error) {
        logger.error(error);
        throw new ApiError(500, error);
      }
    },
    getUnusedAddresses: async (): Promise<Cbor[]> => {
      logger.debug('getting unused addresses');
      return Promise.resolve([]);
    },
    getUsedAddresses: async (_paginate?: Paginate): Promise<Cbor[]> => {
      logger.debug('getting changeAddress');

      const [{ address }] = await firstValueFrom(wallet.addresses$);
      const parsedAddress = parseCslAddress(address.toString());

      if (!address || !parsedAddress) {
        throw new ApiError(500, 'could not get used addresses');
      } else {
        return [Buffer.from(parsedAddress.to_bytes()).toString('hex')];
      }
    },
    getUtxos: async (amount?: Cbor, paginate?: Paginate): Promise<Cardano.Utxo[] | undefined> => {
      let utxos = await firstValueFrom(wallet.utxo.available$);

      if (amount) {
        try {
          const filterAmount = CSL.Value.from_bytes(Buffer.from(amount, 'hex'));
          /**
           * Getting UTxOs to meet a required amount is a complex operation, which is handled by input selection capabilities.
           * By initializing a transaction we're able to utilise the internal configuration and algorithm to make this selection,
           * using a wallet address to satisfy the interface only.
           */
          const { inputSelection } = await wallet.initializeTx({
            outputs: new Set([{ address: wallet.addresses$.value![0].address, value: cslToCore.value(filterAmount) }])
          });

          utxos = [...inputSelection.inputs];
        } catch (error) {
          logger.debug(error);
          throw new ApiError(400, error);
        }
      } else if (paginate) {
        utxos = utxos.slice(paginate.page * paginate.limit, paginate.page * paginate.limit + paginate.limit);
      }

      return Promise.resolve(utxos);
    },
    signData: async (addr: Cardano.Address, payload: Bytes): Promise<Bytes> => {
      logger.debug('signData');
      const { signature } = await cip30signData({
        keyAgent: props.keyAgent,
        payload: Cardano.util.HexBlob(payload),
        signWith: addr
      });
      if (!signature) {
        throw new ApiError(400, 'could not sign data');
      }
      return Promise.resolve(Buffer.from(signature).toString('hex'));
    },
    signTx: async (tx: Cbor, _partialSign?: Boolean): Promise<Cbor> => {
      logger.debug('signTx');
      try {
        const txDecoded = CSL.Transaction.from_bytes(Buffer.from(tx, 'hex'));
        const coreTx = cslToCore.tx(txDecoded);
        const witnessSet = await props.keyAgent.signTransaction({ hash: coreTx.id, body: coreTx.body });

        const cslWitnessSet = coreToCsl.witnessSet(witnessSet);

        return Promise.resolve(Buffer.from(cslWitnessSet.to_bytes()).toString('hex'));
      } catch (error) {
        logger.error(error);
        throw new TxSignError(1, error);
      }
    },
    submitTx: async (tx: Cbor): Promise<string> => {
      logger.debug('submitting tx');
      try {
        const txDecoded = CSL.Transaction.from_bytes(Buffer.from(tx, 'hex'));
        const txData: Cardano.NewTxAlonzo = cslToCore.tx(txDecoded);
        await wallet.submitTx(txData);
        return Promise.resolve(txData.id.toString());
      } catch (error) {
        logger.error(error);
        throw error;
      }
    }
  } as WalletApi;
};

export const createWalletApiAndHandleMessages = (wallet: SingleAddressWallet, props: Props) => {
  const walletApi = createCip30WalletApiFromWallet(wallet, props);
  handleMessages(walletApi, props.logger);
};
