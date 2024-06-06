import { Cardano } from '@cardano-sdk/core';
import { isCip6Format } from './util.js';
import type { APExtMetadataResponse, Cip6ExtMetadataResponse } from './types.js';
import type { StakePoolExtMetadataResponse } from '../types.js';

const mapFromCip6Format = ({ serial, pool }: Cip6ExtMetadataResponse): Cardano.ExtendedStakePoolMetadata => ({
  pool: {
    contact: pool.contact,
    id: Cardano.PoolIdHex(pool.id),
    itn: pool.itn,
    location: pool.country,
    media_assets: pool.media_assets,
    status: pool.status
  },
  serial
});

const mapFromAdaPoolsFormat = ({ info }: APExtMetadataResponse): Cardano.ExtendedStakePoolMetadata => ({
  pool: {
    about: info.about,
    company: info.company,
    contact: {
      discord: info.social?.discord_handle,
      facebook: info.social?.facebook_handle,
      github: info.social?.github_handle,
      telegram: info.social?.telegram_handle,
      twitch: info.social?.twitch_handle,
      twitter: info.social?.twitter_handle,
      youtube: info.social?.youtube_handle
    },
    location: info.location,
    media_assets: {
      icon_png_64x64: info.url_png_icon_64x64,
      logo_png: info.url_png_logo
    }
  }
});

export const mapToExtendedMetadata = (metadata: StakePoolExtMetadataResponse) =>
  isCip6Format(metadata) ? mapFromCip6Format(metadata) : mapFromAdaPoolsFormat(metadata);
