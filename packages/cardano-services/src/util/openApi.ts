import { OpenAPIV3 } from 'express-openapi-validator/dist/framework/types';

export const versionPathFromSpec = (specPath: string) => {
  const apiDoc = require(specPath) as OpenAPIV3.Document;
  return `/v${apiDoc.info.version}`;
};
