import type { OpenAPIV3 } from 'express-openapi-validator/dist/framework/types';

export const versionPathFromSpec = (specPath: string) => {
  try {
    const apiDoc = require(specPath) as OpenAPIV3.Document;

    return `/v${apiDoc.info.version}`;
  } catch (error) {
    throw new Error(
      `Reading version from '${specPath}' due to\n${error instanceof Error ? error.stack : JSON.stringify(error)}\n`
    );
  }
};
