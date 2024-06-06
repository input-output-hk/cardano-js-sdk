import type { Cardano } from '@cardano-sdk/core';
import type { CustomError } from 'ts-custom-error';

/** AdaPools format response types Based on: https://a.adapools.org/extended-example */
export type PoolCompanyInfo = {
  name?: string;
  addr?: string;
  city?: string;
  country?: string;
  company_id?: string;
  vat_id?: string;
};

export type PoolSocialData = {
  twitter_handle?: string;
  telegram_handle?: string;
  facebook_handle?: string;
  youtube_handle?: string;
  twitch_handle?: string;
  discord_handle?: string;
  github_handle?: string;
};

export type PoolAboutInfo = {
  me?: string;
  server?: string;
  company?: string;
};

export type APExtendedStakePoolMetadataFields = {
  url_png_icon_64x64?: string;
  url_png_logo?: string;
  location?: string;
  social?: PoolSocialData;
  company?: PoolCompanyInfo;
  about?: PoolAboutInfo;
};

export type APExtMetadataResponse = {
  info: APExtendedStakePoolMetadataFields;
  [k: string]: unknown;
};

/**
 * CIP-6 format response types
 * Based on: https://raw.githubusercontent.com/cardano-foundation/CIPs/master/CIP-0006/schema.json
 */
export enum ExtendedPoolStatus {
  Active = 'active',
  Retired = 'retired',
  Offline = 'offline',
  Experimental = 'experimental',
  Private = 'private'
}

export type PoolContactData = {
  primary: string;
  email?: string;
  facebook?: string;
  github?: string;
  feed?: string;
  telegram?: string;
  twitter?: string;
};

export type ThePoolsMediaAssets = {
  icon_png_64x64: string;
  logo_png?: string;
  logo_svg?: string;
  color_fg?: string;
  color_bg?: string;
};

export type ITNVerification = {
  owner: string;
  witness: string;
};

export type Cip6ExtendedStakePoolMetadataFields = {
  id: string;
  country?: string;
  status?: ExtendedPoolStatus;
  contact?: PoolContactData;
  media_assets?: ThePoolsMediaAssets;
  itn?: ITNVerification;
};

export type Cip6ExtMetadataResponse = {
  serial: number;
  pool: Cip6ExtendedStakePoolMetadataFields;
};

export type StakePoolMetadataResponse = {
  metadata: Cardano.StakePoolMetadata | undefined;
  errors: CustomError[];
};

export type SmashDelistedResponse = {
  poolId: string;
};
