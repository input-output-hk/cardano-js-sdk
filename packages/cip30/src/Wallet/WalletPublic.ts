import { Wallet } from './Wallet';

export type WalletPublic = Pick<Wallet, 'enable' | 'isEnabled' | 'name' | 'version'>;
