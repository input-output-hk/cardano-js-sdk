import { Cardano } from '../..';
import { OnChainTx } from '../types';

export const isPhase2ValidationErrTx = ({ inputSource }: Pick<OnChainTx, 'inputSource'>): boolean =>
  inputSource === Cardano.InputSource.collaterals;
