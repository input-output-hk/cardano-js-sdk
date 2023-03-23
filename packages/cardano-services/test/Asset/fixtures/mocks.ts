import { createGenericMockServer } from '@cardano-sdk/util-dev';

export const tokenMetadataMockResults: Record<string, unknown> = {
  '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65': {
    description: { value: 'This is my first NFT of the macaron cake' },
    name: { value: 'macaron cake token' },
    subject: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65'
  },
  '728847c7898b06f180de05c80b37d38bf77a9ea22bd1e222b8014d964e46542d66696c6573': {
    description: { value: 'This is my second NFT' },
    name: { value: 'Bored Ape' },
    subject: '728847c7898b06f180de05c80b37d38bf77a9ea22bd1e222b8014d964e46542d66696c6573'
  },
  f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958: {
    decimals: { value: 8 },
    description: { value: 'SingularityNET' },
    logo: { value: 'testLogo' },
    name: { value: 'SingularityNet AGIX Token' },
    subject: 'f43a62fdc3965df486de8a0d32fe800963589c41b38946602a0dc53541474958',
    ticker: { value: 'AGIX' },
    url: { value: 'https://singularitynet.io/' }
  }
};

export const mockTokenRegistry = createGenericMockServer((handler) => async (req, res) => {
  const { body, code } = await handler(req);

  res.setHeader('Content-Type', 'application/json');

  if (body) {
    res.statusCode = code || 200;

    return res.end(JSON.stringify(body));
  }

  const buffers: Buffer[] = [];
  for await (const chunk of req) buffers.push(chunk);
  const data = Buffer.concat(buffers).toString();
  const subjects: unknown[] = [];

  for (const subject of JSON.parse(data).subjects) {
    const mockResult = tokenMetadataMockResults[subject as string];

    if (mockResult) subjects.push(mockResult);
  }

  return res.end(JSON.stringify({ subjects }));
});
