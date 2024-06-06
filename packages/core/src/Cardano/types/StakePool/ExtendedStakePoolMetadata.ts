import type { PoolIdHex } from './primitives.js';
/**
 * Integer number incremented on every update,
 * by using YYYYMMDDxx (xx each day start by 01 and is incremented on each update
 */
export type SerialNumber = number;
/** Stake pool location */
export type DeclaredPoolLocation = string;
/** the current operative status */
export enum ExtendedPoolStatus {
  Active = 'active',
  Retired = 'retired',
  Offline = 'offline',
  Experimental = 'experimental',
  Private = 'private'
}
/** the pools preferred communication channel */
export type PrimaryContactPreference = string;
/** valid email contact address */
export type EmailAddress = string;
/** a user or page name */
export type FacebookAccount = string;
/** a github account */
export type GithubAccount = string;
/** RSS feed URL */
export type RSSFeed = string;
/** a telegram account */
export type TelegramAccount = string;
/** a twitter account */
export type TwitterAccount = string;
/** a youtube account or channel name */
export type YoutubeAccount = string;
/** a discord account or channel name */
export type DiscordAccount = string;
/** a twitch account */
export type TwitchAccount = string;
/** PNG image with exact 64x64 pixel size */
export type PoolIconInPNGFileFormat64X64Px = string;
/** PNG image (should have less than 250 kByte of file size) */
export type PoolLogoInPNGFileFormat = string;
/** (should have less tha 250 kByte of file size) */
export type PoolLogoInSVGFileFormat = string;
/** RGB color code. */
export type PoolPrimaryColor = string;
/** RGB color code. */
export type PoolSecondaryColor = string;
/** The ITN pool's owner public key */
export type TheITNPoolOwnerPublicKey = string;
/** The witness's secret generated key */
export type TheSecretKeyGeneratedWitness = string;
/** Stake Pool about info */
export type MeAboutInfo = string;
/** Stake Pool server info */
export type ServerAboutInfo = string;
/** Stake Pool company about info */
export type CompanyAboutInfo = string;
/** Stake Pool company name */
export type CompanyName = string;
/** Stake Pool company address */
export type CompanyAddress = string;
/** Stake Pool company city */
export type CompanyCity = string;
/** Stake Pool company country */
export type CompanyCountry = string;
/** Stake Pool company id */
export type CompanyId = string;
/** Stake Pool company VAT id */
export type CompanyVatId = string;

/** Optional contact information. */
export interface PoolContactData {
  primary?: PrimaryContactPreference;
  email?: EmailAddress;
  facebook?: FacebookAccount;
  github?: GithubAccount;
  feed?: RSSFeed;
  telegram?: TelegramAccount;
  twitter?: TwitterAccount;
  twitch?: TwitchAccount;
  youtube?: YoutubeAccount;
  discord?: DiscordAccount;
  [k: string]: unknown;
}

/** Media file URLs and colors */
export interface ThePoolsMediaAssets {
  icon_png_64x64?: PoolIconInPNGFileFormat64X64Px;
  logo_png?: PoolLogoInPNGFileFormat;
  logo_svg?: PoolLogoInSVGFileFormat;
  color_fg?: PoolPrimaryColor;
  color_bg?: PoolSecondaryColor;
  [k: string]: unknown;
}

/** A proof of ownership for an established ITN pool brand. */
export interface ITNVerification {
  owner?: TheITNPoolOwnerPublicKey;
  witness?: TheSecretKeyGeneratedWitness;
  [k: string]: unknown;
}

/** Optional company information. */
export interface PoolCompanyInfo {
  name?: CompanyName;
  addr?: CompanyAddress;
  city?: CompanyCity;
  country?: CompanyCountry;
  company_id?: CompanyId;
  vat_id?: CompanyVatId;
  [k: string]: unknown;
}

/** Optional about information. */
export interface PoolAboutInfo {
  me?: MeAboutInfo;
  server?: ServerAboutInfo;
  company?: CompanyAboutInfo;
  [k: string]: unknown;
}

/** pool related metadata */
export interface ExtendedStakePoolMetadataFields {
  id?: PoolIdHex;
  location?: DeclaredPoolLocation;
  status?: ExtendedPoolStatus;
  contact?: PoolContactData;
  media_assets?: ThePoolsMediaAssets;
  itn?: ITNVerification;
  company?: PoolCompanyInfo;
  about?: PoolAboutInfo;
  [k: string]: unknown;
}

/** additional information for Cardano Stake Pools */
export interface ExtendedStakePoolMetadata {
  serial?: SerialNumber;
  pool: ExtendedStakePoolMetadataFields;
  [k: string]: unknown;
}
