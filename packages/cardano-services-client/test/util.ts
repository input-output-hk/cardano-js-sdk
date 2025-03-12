import { Asset, Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { AxiosError, AxiosResponse } from 'axios';
import { IHandle, Rarity } from '@koralabs/handles-public-api-interfaces';
import { logger } from '@cardano-sdk/util-dev';
import { toSerializableObject } from '@cardano-sdk/util';

export const config = { baseUrl: 'http://some-hostname:3000', logger };

export const axiosError = (bodyError = new Error('error')) => {
  const response = {
    data: toSerializableObject(new ProviderError(ProviderFailure.BadRequest, bodyError))
  } as AxiosResponse;
  const error = new AxiosError(undefined, undefined, undefined, undefined, response);
  Object.defineProperty(error, 'response', { value: response });
  return error;
};

export const healthCheckResponseWithState = {
  localNode: {
    ledgerTip: {
      blockNo: 3_391_731,
      hash: '9ef43ab6e234fcf90d103413096c7da752da2f45b15e1259f43d476afd12932c',
      slot: 52_819_355
    },
    networkSync: 0.999
  },
  ok: true
};

export const getWrongHandleProviderResponse = {
  cardanoAddress: Cardano.PaymentAddress(
    'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  ),
  handle: 'Mary',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3254db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  resolvedAt: {
    hash: Cardano.BlockId('10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0'),
    slot: Cardano.Slot(37_834_496)
  }
};

export const getAliceHandleProviderResponse = {
  backgroundImage: undefined,
  cardanoAddress:
    'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd',
  handle: 'alice',
  hasDatum: false,
  image: Asset.Uri('ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasd'),
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  profilePic: undefined
};

export const getBobHandleProviderResponse = {
  backgroundImage: Asset.Uri('ipfs://zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd'),
  cardanoAddress:
    'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g',
  handle: 'bob',
  hasDatum: false,
  image: Asset.Uri('ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe'),
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  profilePic: Asset.Uri('ipfs://zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd1')
};

export const getAliceHandleAPIResponse: Partial<IHandle> = {
  characters: 'rljm7n/23455',
  created_slot_number: 33,
  default_in_wallet: 'alice_default_hndle',
  has_datum: false,
  hex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
  holder: 'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw',
  image: 'ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasd',
  length: 123,
  name: 'alice',
  numeric_modifiers: '-12.9',
  og_number: 5,
  rarity: Rarity.rare,
  resolved_addresses: {
    ada: 'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  },
  standard_image: 'ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasdfasd',
  updated_slot_number: 22,
  utxo: 'rljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0'
};

export const getBobHandleAPIResponse: Partial<IHandle> = {
  bg_image: 'ipfs://zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd',
  characters: 'rljm7n/23455',
  created_slot_number: 33,
  default_in_wallet: 'bob_default_handle',
  has_datum: false,
  hex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
  holder: 'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw',
  image: 'ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe',
  length: 123,
  name: 'bob',
  numeric_modifiers: '-12.9',
  og_number: 5,
  pfp_image: 'ipfs://zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd1',
  rarity: Rarity.rare,
  resolved_addresses: {
    ada: 'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g'
  },
  standard_image: 'ipfs://c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasdfasd',
  updated_slot_number: 22,
  utxo: 'rljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0'
};

export const mockResponses = (request: jest.Mock, responses: [string | RegExp, unknown][]) => {
  request.mockImplementation(async (endpoint: string) => {
    for (const [match, response] of responses) {
      if (typeof match === 'string') {
        if (match === endpoint) {
          if (response instanceof Error) throw response;
          return response;
        }
      } else if (match.test(endpoint)) {
        return response;
      }
    }
    throw new Error(`Not implemented/matched: ${endpoint}`);
  });
};
