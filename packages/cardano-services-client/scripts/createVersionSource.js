const fs = require('fs');
const path = require('path');

const openApiSpec = require('../../cardano-services/src/Http/openApi.json');

const contents = `// auto-generated using ../scripts/createVersionSource.js
export const apiVersion = '${openApiSpec.info.version}';
`;

fs.writeFileSync(path.join(__dirname, '../src/version.ts'), contents, { encoding: 'utf8', flag: 'w' });
