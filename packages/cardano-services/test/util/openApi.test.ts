import { versionPathFromSpec } from '../../src/util/openApi.js';
import path from 'path';
import type { OpenAPIV3 } from 'express-openapi-validator/dist/framework/types';

describe('openApi utils', () => {
  describe('versionPathFromSpec', () => {
    it('parses the OpenAPI version and returns as a path, prefixed with v', () => {
      const apiSpecPath = path.join(__dirname, '..', '..', 'src', 'Http', 'openApi.json');
      const {
        info: { version }
      } = require(apiSpecPath) as OpenAPIV3.Document;
      expect(version).not.toBeUndefined();
      expect(versionPathFromSpec(apiSpecPath)).toBe(`/v${version}`);
    });
  });
});
