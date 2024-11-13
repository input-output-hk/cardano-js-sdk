export const mockResponses = (request: jest.Mock, responses: [string | RegExp, unknown][]) => {
  request.mockImplementation(async (endpoint: string) => {
    for (const [match, response] of responses) {
      if (typeof match === 'string') {
        if (match === endpoint) return response;
      } else if (match.test(endpoint)) {
        return response;
      }
    }
    throw new Error(`Not implemented/matched: ${endpoint}`);
  });
};
