/* eslint-disable @typescript-eslint/no-explicit-any */
import { WalletApi } from '../Wallet';

export type Message = { method: keyof WalletApi; arguments: [any?, any?] };
