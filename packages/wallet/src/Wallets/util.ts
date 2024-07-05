import { AddressDiscovery, HDSequentialDiscovery } from '../services';
import {
  BaseWallet,
  BaseWalletDependencies,
  BaseWalletProps,
  PublicCredentialsManager,
  PublicCredentialsManagerType
} from './BaseWallet';
import { Bip32Account } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

export const DEFAULT_LOOK_AHEAD_SEARCH = 20;

export const isValidSharedWalletScript = (script: Cardano.NativeScript): boolean => {
  switch (script.kind) {
    case Cardano.NativeScriptKind.RequireAllOf:
    case Cardano.NativeScriptKind.RequireAnyOf:
    case Cardano.NativeScriptKind.RequireNOf:
      return script.scripts.every((nativeScript) => nativeScript.kind === Cardano.NativeScriptKind.RequireSignature);
    default:
      return false;
  }
};

export type PersonalWalletDependencies = Omit<BaseWalletDependencies, 'publicCredentialsManager'> & {
  bip32Account: Bip32Account;
  addressDiscovery?: AddressDiscovery;
};

export type ScriptWalletDependencies = Omit<BaseWalletDependencies, 'publicCredentialsManager'> & {
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
};

export const createPersonalWallet = (props: BaseWalletProps, dependencies: PersonalWalletDependencies): BaseWallet => {
  const publicCredentialsManager: PublicCredentialsManager = {
    __type: PublicCredentialsManagerType.BIP32_CREDENTIALS_MANAGER,
    addressDiscovery: dependencies.addressDiscovery
      ? dependencies.addressDiscovery
      : new HDSequentialDiscovery(dependencies.chainHistoryProvider, DEFAULT_LOOK_AHEAD_SEARCH),
    bip32Account: dependencies.bip32Account
  };

  return new BaseWallet(props, { ...dependencies, publicCredentialsManager });
};

export const createSharedWallet = (props: BaseWalletProps, dependencies: ScriptWalletDependencies): BaseWallet => {
  if (!isValidSharedWalletScript(dependencies.paymentScript) || !isValidSharedWalletScript(dependencies.stakingScript))
    throw new Error(
      'SharedWallet requires the scripts to be of type "RequireAllOfScript" or "RequireAnyOfScript" or "RequireAtLeastScript"'
    );

  const publicCredentialsManager: PublicCredentialsManager = {
    __type: PublicCredentialsManagerType.SCRIPT_CREDENTIALS_MANAGER,
    paymentScript: dependencies.paymentScript,
    stakingScript: dependencies.stakingScript
  };

  return new BaseWallet(props, { ...dependencies, publicCredentialsManager });
};
