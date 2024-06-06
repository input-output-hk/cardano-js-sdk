import { Cardano } from '../../index.js';
import type { OnChainTx } from '../types/index.js';

export const isPhase2ValidationErrTx = ({ inputSource }: Pick<OnChainTx, 'inputSource'>): boolean =>
  inputSource === Cardano.InputSource.collaterals;
