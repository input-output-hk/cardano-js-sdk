import { PersistentAuthenticator, createPersistentAuthenticatorStorage } from '@cardano-sdk/cip30';
import { logger, walletName } from '../util';
import { requestAccess } from './requestAccess';
import { storage } from 'webextension-polyfill';

const authenticatorStorage = createPersistentAuthenticatorStorage(`${walletName}Origins`, storage.local);

export const authenticator = new PersistentAuthenticator({ requestAccess }, { logger, storage: authenticatorStorage });
