import { Cardano } from '@cardano-sdk/core';
import type { APExtMetadataResponse, Cip6ExtMetadataResponse } from '../../../src/index.js';

export const mainExtMetadataMock = () => ({
  description: 'pool desc',
  homepage: 'https://teststakepool.com',
  name: 'testnet-stake-pool',
  ticker: 'TESTNET'
});

export const adaPoolsExtMetadataMock: APExtMetadataResponse = {
  info: {
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
    location: 'London, England',
    social: {
      discord_handle: '',
      facebook_handle: '',
      github_handle: '',
      telegram_handle: 'adapools_ops',
      twitch_handle: '',
      twitter_handle: 'adapools_org',
      youtube_handle: ''
    },
    url_png_icon_64x64: 'http(s) url to pool icon; png format; not animated; max 40kb',
    url_png_logo: 'http(s) url to pool logo; png format; not animated; max 50kb'
  }
};

export const cip6ExtMetadataMock: Cip6ExtMetadataResponse = {
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
    country: 'DE',
    id: '4a2e3b7f4a78ff1452b91329a7673c77c98ca96dece7b55c37869502',
    itn: {
      owner: 'ed25519_pk1...',
      witness: 'ed25519_sig1...'
    },
    media_assets: {
      color_bg: '#RRGGBB',
      color_fg: '#RRGGBB',
      icon_png_64x64: 'https://mydemopool.com/icon.png',
      logo_png: 'https://mydemopool.com/logo.png',
      logo_svg: 'https://mydemopool.com/logo.svg'
    },
    status: Cardano.ExtendedPoolStatus.Active
  },
  serial: 2_020_072_001
};

export const stakePoolMetadata: Cardano.StakePoolMetadata = {
  description: 'Stakepool - Your reliable & trustworthy stakepool',
  extended: 'http://localhost/extendedMetadata',
  homepage: 'https://www.home-page.com',
  name: 'Stakepool #1',
  ticker: 'STKP'
};
