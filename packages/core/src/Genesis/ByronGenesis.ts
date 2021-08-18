export interface ByronGenesis {
  bootStakeholders: { [k: string]: number };
  heavyDelegation: {
    [k: string]: {
      omega: number;
      issuerPk: string;
      delegatePk: string;
      cert: string;
    };
  };
  startTime: number;
  vssCerts: {
    [k: string]: {
      vssKey: string;
      expiryEpoch: number;
      signature: string;
      signingKey: string;
    };
  };
  nonAvvmBalances: { [k: string]: string };
  blockVersionData: {
    scriptVersion: number;
    slotDuration: string;
    maxBlockSize: string;
    maxHeaderSize: string;
    maxTxSize: string;
    maxProposalSize: string;
    mpcThd: string;
    heavyDelThd: string;
    updateVoteThd: string;
    updateProposalThd: string;
    updateImplicit: string;
    softforkRule: {
      initThd: string;
      minThd: string;
      thdDecrement: string;
    };
    txFeePolicy: {
      summand: string;
      multiplier: string;
    };
    unlockStakeEpoch: string;
  };
  protocolConsts: {
    k: number;
    protocolMagic: string;
    vssMaxTTL: number;
    vssMinTTL: number;
  };
  avvmDistr: { [k: string]: string };
  ftsSeed: string;
}
