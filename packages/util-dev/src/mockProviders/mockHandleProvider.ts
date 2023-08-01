import { Cardano } from '@cardano-sdk/core';

export const resolvedHandle = {
  cardanoAddress: Cardano.PaymentAddress(
    'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
  ),
  handle: 'alice',
  hasDatum: false,
  policyId: Cardano.PolicyId('50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb'),
  resolvedAt: {
    hash: Cardano.BlockId('10d64cc11e9b20e15b6c46aa7b1fed11246f437e62225655a30ea47bf8cc22d0'),
    slot: Cardano.Slot(37_834_496)
  }
};

export const mockHandleProvider = () => ({
  healthCheck: jest.fn().mockResolvedValue({ ok: true }),
  resolveHandles: jest.fn().mockResolvedValue([resolvedHandle])
});
