import { Cardano } from '@cardano-sdk/core';
import { Ed25519KeyHashHex } from '@cardano-sdk/crypto';

type ScriptType = number;

interface MultiSigParticipant {
  name: string;
  description?: string;
  icon?: string;
}

interface MultiSigParticipants {
  [key: Ed25519KeyHashHex]: MultiSigParticipant;
}

export interface MultiSigRegistration {
  types: ScriptType[];
  name?: string;
  description?: string;
  icon?: string;
  participants?: MultiSigParticipants;
}

export interface MultiSigTransaction {
  txId: Cardano.TransactionId;
  metadata: MultiSigRegistration;
  nativeScripts?: Cardano.Script[];
}

export interface SharedWalletProvider {
  discoverWallets: (pubKey: Ed25519KeyHashHex) => Promise<MultiSigTransaction[]>;
}
