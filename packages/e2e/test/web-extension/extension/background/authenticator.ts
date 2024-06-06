import { PersistentAuthenticator, createPersistentAuthenticatorStorage } from '@cardano-sdk/dapp-connector';
import { logger } from '../util.js';
import { requestAccess } from './requestAccess.js';
import { storage } from 'webextension-polyfill';
import { walletName } from '../const.js';

const authenticatorStorage = createPersistentAuthenticatorStorage(`${walletName}Origins`, storage.local);

export const authenticator = new PersistentAuthenticator({ requestAccess }, { logger, storage: authenticatorStorage });
