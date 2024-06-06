import { AxiosError } from 'axios';
import { Cardano, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { toSerializableObject } from '@cardano-sdk/util';
import type { AxiosResponse } from 'axios';

export const axiosError = (bodyError: Error | null = new Error('error'), reason = ProviderFailure.BadRequest) => {
  const response = {
    data: toSerializableObject(new ProviderError(reason, bodyError))
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
  cardanoAddress: Cardano.PaymentAddress('addr_test1vr8nl4u0u6fmtfnawx2rxfz95dy7m46t6dhzdftp2uha87syeufdg'),
  handle: 'Mary',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3254db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  resolvedAt: {
    hash: Cardano.BlockId('10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0'),
    slot: Cardano.Slot(37_834_496)
  }
};

export const getAliceHandleProviderResponse = {
  cardanoAddress: Cardano.PaymentAddress(
    'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  ),
  handle: 'alice',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb')
};

export const getBobHandleProviderResponse = {
  cardanoAddress: Cardano.PaymentAddress(
    'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  ),
  handle: 'bob',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb')
};

export const getAliceHandleAPIResponse = {
  background: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd',
  characters: 'rljm7n/23455',
  created_slot_number: 33,
  default_in_wallet: 'alice_default_hndle',
  hasDatum: false,
  hex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
  holder_address: 'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw',
  length: 123,
  name: 'alice',
  nft_image: 'c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe',
  numeric_modifiers: '-12.9',
  og: 5,
  original_nft_image: 'c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasdfasd',
  profile_pic: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd',
  rarity: 'rare',
  resolved_addresses: {
    ada: 'addr_test1qqk4sr4f7vtqzd2w90d5nfu3n59jhhpawyphnek2y7er02nkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuqmcnecd'
  },
  updated_slot_number: 22,
  utxo: 'rljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0'
};

export const getBobHandleAPIResponse = {
  background: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd',
  characters: 'rljm7n/23455',
  created_slot_number: 33,
  default_in_wallet: 'bob_default_handle',
  hasDatum: false,
  hex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
  holder_address: 'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw',
  length: 123,
  name: 'bob',
  nft_image: 'c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe',
  numeric_modifiers: '-12.9',
  og: 5,
  original_nft_image: 'c8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56feasdfasd',
  profile_pic: 'zrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3yd',
  rarity: 'rare',
  resolved_addresses: {
    ada: 'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g'
  },
  updated_slot_number: 22,
  utxo: 'rljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0'
};
