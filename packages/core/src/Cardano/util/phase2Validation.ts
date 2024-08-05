import { InputSource, OnChainTx } from '../types/Transaction';

export const isPhase2ValidationErrTx = ({ inputSource }: Pick<OnChainTx, 'inputSource'>): boolean =>
  inputSource === InputSource.collaterals;
