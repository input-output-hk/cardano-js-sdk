import { PersistentAuthenticator, createPersistentAuthenticatorStorage } from '@cardano-sdk/dapp-connector';
import { logger } from '../util';
import { requestAccess } from './requestAccess';
import { storage } from 'webextension-polyfill';
import { walletName } from '../const';

const authenticatorStorage = createPersistentAuthenticatorStorage(`${walletName}Origins`, storage.local);

export const authenticator = new PersistentAuthenticator({ requestAccess }, { logger, storage: authenticatorStorage });
