import { OpenAPIV3 } from 'express-openapi-validator/dist/framework/types';
import { versionPathFromSpec } from '../../src/util/openApi';
import path from 'path';

describe('openApi utils', () => {
  describe('versionPathFromSpec', () => {
    it('parses the OpenAPI version and returns as a path, prefixed with v', () => {
      const apiSpecPath = path.join(__dirname, '..', '..', 'src', 'Http', 'openApi.json');
      const {
        info: { version }
      } = require(apiSpecPath) as OpenAPIV3.Document;
      expect(versionPathFromSpec(apiSpecPath)).toBe(`/v${version}`);
    });
  });
});
