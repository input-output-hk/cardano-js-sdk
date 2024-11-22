import { DRepInfo, GetDRepInfoArgs, GetDRepsInfoArgs } from '@cardano-sdk/core';

export const mockDrepProvider = () => ({
  getDRepInfo: jest
    .fn()
    .mockImplementation(
      ({ id }: GetDRepInfoArgs): Promise<DRepInfo> =>
        Promise.resolve({ active: true, amount: 0n, hasScript: false, id })
    ),
  getDRepsInfo: jest
    .fn()
    .mockImplementation(
      ({ ids }: GetDRepsInfoArgs): Promise<DRepInfo[]> =>
        Promise.resolve(ids.map((id) => ({ active: true, amount: 0n, hasScript: false, id })))
    ),
  healthCheck: jest.fn().mockResolvedValue({ ok: true })
});

export type MockDrepProvider = ReturnType<typeof mockDrepProvider>;
