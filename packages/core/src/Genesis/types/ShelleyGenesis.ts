export interface ShelleyGenesis {
  activeSlotsCoeff: number;
  protocolParams: {
    protocolVersion: {
      minor: number;
      major: number;
    };
    decentralisationParam: number;
    eMax: number;
    extraEntropy: {
      tag: string;
    };
    maxTxSize: number;
    maxBlockBodySize: number;
    maxBlockHeaderSize: number;
    minFeeA: number;
    minFeeB: number;
    minUTxOValue: number;
    poolDeposit: number;
    minPoolCost: number;
    keyDeposit: number;
    nOpt: number;
    rho: number;
    tau: number;
    a0: number;
  };
  genDelegs?: {
    [k: string]: {
      delegate: string;
      vrf: string;
    };
  };
  updateQuorum: number;
  networkId: 'Mainnet' | 'Testnet';
  initialFunds: {};
  maxLovelaceSupply: number;
  networkMagic: number;
  epochLength: number;
  systemStart: string;
  slotsPerKESPeriod: number;
  slotLength: number;
  maxKESEvolutions: number;
  securityParam: number;
}
