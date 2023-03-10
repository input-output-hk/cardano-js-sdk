export const retirement = {
  retiringEpoch: 78,
  transactionId: 'c27b294bb3dfbdfeda19b7f0254b23f91e3a48a2111c52dd99da6f1c8c3ff74f'
};

export const registration = {
  activeEpochNo: '76',
  transactionId: '295d5e0f7ee182426eaeda8c9f1c63502c72cdf4afd6e0ee0f209adf94a614e7'
};

export const epochReward = {
  epochReward: {
    activeStake: 497_443_657n,
    epoch: 77,
    epochLength: 431_980_000,
    leaderRewards: 10n,
    memberROI: 0,
    memberRewards: 100n,
    pledge: 97_443_657n
  },
  hashId: 6
};

export const relay = {
  hashId: 2,
  relay: {
    __typename: 'RelayByAddress',
    ipv4: '127.0.0.1',
    ipv6: null,
    port: 3001
  },
  updateId: 6
};

export const metrics = {
  activeStake: 0n,
  activeStakePercentage: 0,
  blocksCreated: 0,
  delegators: 1,
  livePledge: 999_999_828_559n,
  liveStake: 999_999_828_559n,
  saturation: 0.011_898_674_769_756_331
};

export const info = {
  cost: 0n,
  hexId: 'd1f77070596c89d58bf5cc65843b004b2c47f9bf6c8e52df49580a0f',
  id: 'pool168mhquzedjyatzl4e3jcgwcqfvky07dldj899h6ftq9q7fzzvry',
  margin: { denominator: 1, numerator: 0 },
  pledge: 0n,
  rewardAccount: 'stake_test1uzksuwayv930mvkas0hfe5cdshtwszpp06nvjs9y6rtugmstddurm',
  vrfKeyHash: '60b53eb77b516ae37f7f1cffa7ca83a1017a92cff49cb42724a4fdc94a11a65a'
};

export const adaPoolExtendedMetadata = {
  pool: {
    about: {
      company: 'IOHK',
      me: 'Cardano',
      server: 'Raspberry Pi Hosted at my Home'
    },
    company: {
      addr: 'Street, Number',
      city: 'London',
      company_id: '123456789',
      country: 'England',
      name: 'Company Name',
      vat_id: 'GB123456789'
    },
    contact: {
      discord: '',
      facebook: '',
      github: '',
      telegram: 'adapools_ops',
      twitch: '',
      twitter: 'adapools_org',
      youtube: ''
    },
    location: 'London, England',
    media_assets: {
      icon_png_64x64: 'http(s) url to pool icon; png format; not animated; max 40kb',
      logo_png: 'http(s) url to pool logo; png format; not animated; max 50kb'
    }
  }
};

export const cip6ExtendedMetadata = {
  pool: {
    contact: {
      email: 'help@pooldomain.org',
      facebook: 'demopool',
      feed: 'https://demopool.com/xml/poolrss.xml',
      github: 'demopool',
      primary: 'email',
      telegram: 'demopool',
      twitter: 'demopool'
    },
    id: '4a2e3b7f4a78ff1452b91329a7673c77c98ca96dece7b55c37869502',
    itn: { owner: 'ed25519_pk1...', witness: 'ed25519_sig1...' },
    location: 'DE',
    media_assets: {
      color_bg: '#RRGGBB',
      color_fg: '#RRGGBB',
      icon_png_64x64: 'https://mydemopool.com/icon.png',
      logo_png: 'https://mydemopool.com/logo.png',
      logo_svg: 'https://mydemopool.com/logo.svg'
    },
    status: 'active'
  },
  serial: 2_020_072_001
};

export const stakePoolResults = { pageResults: [], totalResultCount: 0 };
export const stakePoolResult = {
  epochRewards: [
    {
      activeStake: 13_958_004_965_545_733n,
      epoch: 151,
      epochLength: 112_600,
      leaderRewards: 10n,
      memberROI: 0.000_074_882_188_185_275_1,
      memberRewards: 100n,
      pledge: 958_004_965_545_733n
    }
  ],
  hexId: 'a3ea0e70b6d9a9a149017379301b3e98ea9e3addbdd49935aabb56f5',
  id: 'pool1504quu9kmx56zjgpwdunqxe7nr4fuwkahh2fjdd2hdt020rckh7',
  margin: { denominator: 20, numerator: 3 },
  metadata: {
    description: 'This is the stake pool 1 description.',
    homepage: 'https://stakepool1.com',
    name: 'Stake Pool - 1',
    ticker: 'SP1'
  },
  metadataJson: {
    hash: '8e895fb2b685c1fcbb63abd25ec861824fd20d6f65404f01f4a0981e05f6127f',
    url: 'http://file-server/SP1.json'
  },
  metrics: {
    apy: 24_104_181_317_695.1,
    blocksCreated: '5114',
    delegators: '1',
    livePledge: 133_794_551_745n,
    saturation: 17.233_616_175_541_613,
    size: { active: 0.999_911_886_355_716_5, live: 0.000_088_113_644_283_516_2 },
    stake: { active: 13_958_004_965_545_733n, live: 13_959_234_964_609_875n }
  },
  owners: ['stake_test1uqr53ts66tuhlm8f99f09ycwy2nuy7mqj5hccx72s4q5yssfl60a6'],
  pledge: 0n,
  relays: [{ __typename: 'RelayByAddress', ipv4: '127.0.0.1', ipv6: null, port: 3001 }],
  rewardAccount: 'stake_test1uqr53ts66tuhlm8f99f09ycwy2nuy7mqj5hccx72s4q5yssfl60a6',
  status: 'active',
  transactions: {
    registration: [
      'c832201b86ea2b1ca6d62f0d2f9499a7716518f88cf70f06addf0213da6e0356',
      '5368656c6c65792047656e65736973205374616b696e67205478204861736820'
    ],
    retirement: []
  },
  vrf: '86be64c4d9b6db64e841c548ff4b709eb70c6715a863074581a9f11ef8b541e9'
};

export const pool = [
  retirement,
  registration,
  epochReward,
  relay,
  metrics,
  info,
  cip6ExtendedMetadata,
  adaPoolExtendedMetadata,
  stakePoolResults,
  stakePoolResult
];
