/* eslint-disable max-len */
/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable max-depth */

import * as CML from '@dcspark/cardano-multiplatform-lib-nodejs';
import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { CustomError } from 'ts-custom-error';
import { Hash32ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { StakePoolExtMetadataResponse, StakePoolMetadataService } from '../types';
import { StakePoolMetadataResponse } from '../..';
import { ValidationError, validate } from 'jsonschema';
import { getExtMetadataUrl, getSchemaFormat, loadJsonSchema } from './util';
import { mapToExtendedMetadata } from './mappers';
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import blake2b from 'blake2b';

const HTTP_CLIENT_TIMEOUT = 1 * 1000;
const HTTP_CLIENT_MAX_CONTENT_LENGTH = 5000;
const SERVICE_NAME = 'StakePoolMetadataService';

export const createHttpStakePoolMetadataService = (
  logger: Logger,
  axiosClient: AxiosInstance = axios.create({
    maxContentLength: HTTP_CLIENT_MAX_CONTENT_LENGTH,
    timeout: HTTP_CLIENT_TIMEOUT
  })
): StakePoolMetadataService => ({
  async getStakePoolExtendedMetadata(
    metadata: Cardano.StakePoolMetadata,
    config: AxiosRequestConfig = {}
  ): Promise<Cardano.ExtendedStakePoolMetadata> {
    const url = getExtMetadataUrl(metadata);
    try {
      logger.debug('About to fetch stake pool extended metadata');
      const { data } = await axiosClient.get<StakePoolExtMetadataResponse>(url, config);
      const schema = loadJsonSchema(getSchemaFormat(metadata));
      validate(data, schema, { throwError: true });
      return mapToExtendedMetadata(data);
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 404) {
          throw new ProviderError(
            ProviderFailure.NotFound,
            error,
            `${SERVICE_NAME} failed to fetch extended metadata from ${url} due to resource not found`
          );
        }

        throw new ProviderError(
          ProviderFailure.ConnectionFailure,
          error,
          `${SERVICE_NAME} failed to fetch extended metadata from ${url} due to connection error`
        );
      }
      if (error instanceof ValidationError) {
        throw new ProviderError(
          ProviderFailure.InvalidResponse,
          error,
          'Extended metadata JSON format validation failed against the corresponding schema for correctness'
        );
      }
      throw error;
    }
  },
  async getStakePoolMetadata(hash: Hash32ByteBase16, url: string): Promise<StakePoolMetadataResponse> {
    const errors = [];
    let metadata: Cardano.StakePoolMetadata | undefined;
    let extMetadata: Cardano.ExtendedStakePoolMetadata | undefined;

    try {
      logger.debug(`About to fetch stake pool metadata JSON from ${url}`);

      // Fetch metadata as byte array
      const { data } = await axiosClient.get<Uint8Array>(url, { responseType: 'arraybuffer' });
      // Produce metadata hash
      const metadataHash = blake2b(blake2b.BYTES).update(data).digest('hex');

      // Verify base hashes
      if (metadataHash !== hash) {
        return { errors: [new CustomError('Invalid stake pool hash')], metadata };
      }

      // Transform fetched metadata from bytes array to JSON
      metadata = JSON.parse(data.toString());

      if (metadata?.extDataUrl || metadata?.extended) {
        // Validate CIP-6 ext metadata fields
        if (metadata.extDataUrl && (!metadata.extSigUrl || !metadata.extVkey)) {
          return { errors: [new CustomError('Invalid metadata: Missing ext signature or public key')], metadata };
        }

        // Fetch extended metadata (supports both cip-6 and ada pools formats already)
        extMetadata = await this.getStakePoolExtendedMetadata(metadata);

        // In case of CIP-6 standard -> perform signature verification
        if (metadata.extDataUrl && metadata.extSigUrl && metadata.extVkey) {
          // Based on the CIP-6, we have `extSigUrl` (A URL with the extended metadata signature), so we need to make another HTTP request to get the actual signature
          try {
            const signature = (await axiosClient.get<Crypto.Ed25519SignatureHex>(metadata.extSigUrl)).data;
            const message = HexBlob.fromBytes(Buffer.from(JSON.stringify(extMetadata)));
            const publicKey = Crypto.Ed25519PublicKeyHex(metadata.extVkey);
            const bip32Ed25519 = new Crypto.CmlBip32Ed25519(CML);

            // Verify the signature
            const isSignatureValid = await bip32Ed25519.verify(signature, message, publicKey);

            // If not valid -> omit extended metadata from response and add specific error
            if (!isSignatureValid) {
              extMetadata = undefined;
              errors.push(new CustomError('Invalid extended metadata signature'));
            }
            // If signature url failed -> omit extended metadata from response and add specific error
          } catch {
            extMetadata = undefined;
            errors.push(
              new CustomError(
                `${SERVICE_NAME} failed to fetch ext signature from ${metadata.extSigUrl} due to connection error`
              )
            );
          }
        }
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        errors.push(
          new ProviderError(
            ProviderFailure.ServerUnavailable,
            error.toJSON(),
            `${SERVICE_NAME} failed to fetch metadata JSON from ${url} due to ${error.message}`
          )
        );
      } else if (error instanceof ProviderError) {
        errors.push(new ProviderError(error.reason, error.innerError, error.detail));
      }
    }

    return { errors, metadata: { ...metadata!, ext: extMetadata } };
  }
});
