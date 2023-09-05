/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import {
  CommunicationType,
  KeyAgentDependencies,
  SerializableTrezorKeyAgentData,
  SignBlobResult,
  TrezorConfig
} from './types';
import { KeyAgentBase } from './KeyAgentBase';
import TrezorConnectNode, { Features } from '@trezor/connect';
import TrezorConnectWeb from '@trezor/connect-web';

export interface TrezorKeyAgentProps extends Omit<SerializableTrezorKeyAgentData, '__typename'> {
  isTrezorInitialized?: boolean;
}

export interface GetTrezorXpubProps {
  accountIndex: number;
  communicationType: CommunicationType;
}

export interface CreateTrezorKeyAgentProps {
  chainId: Cardano.ChainId;
  accountIndex?: number;
  trezorConfig: TrezorConfig;
}

export type TrezorConnectInstanceType = typeof TrezorConnectNode | typeof TrezorConnectWeb;

export class TrezorKeyAgent extends KeyAgentBase {
  static async initializeTrezorTransport(__config: TrezorConfig): Promise<boolean> {
    throw new NotImplementedError('initializeTrezorTransport');
  }

  static async checkDeviceConnection(_communicationType: CommunicationType): Promise<Features> {
    throw new NotImplementedError('checkDeviceConnection');
  }

  static async getXpub(_props: GetTrezorXpubProps): Promise<Crypto.Bip32PublicKeyHex> {
    throw new NotImplementedError('getXpub');
  }

  static async createWithDevice(
    _props: CreateTrezorKeyAgentProps,
    _dependencies: KeyAgentDependencies
  ): Promise<TrezorKeyAgent> {
    throw new NotImplementedError('createWithDevice');
  }

  async signTransaction(_body: Cardano.TxBodyWithHash): Promise<Cardano.Signatures> {
    throw new NotImplementedError('signTransaction');
  }

  async signBlob(): Promise<SignBlobResult> {
    throw new NotImplementedError('signBlob');
  }

  async exportRootPrivateKey(): Promise<Crypto.Bip32PrivateKeyHex> {
    throw new NotImplementedError('Operation not supported!');
  }
}
