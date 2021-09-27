import fs from 'fs-extra';
import path from 'path';
import url from 'url';

const rootDir = path.dirname(url.fileURLToPath(import.meta.url));

const coverageIndexDir = path.join(rootDir, 'docs', 'coverage');
if (!fs.existsSync(coverageIndexDir)) {
  fs.mkdirSync(coverageIndexDir);
}

const packagesDir = path.join(rootDir, 'packages');
for (const packageName of fs.readdirSync(packagesDir)) {
  const packageDir = path.join(packagesDir, packageName);
  if (!fs.lstatSync(packageDir).isDirectory()) continue;
  const coverageDir = path.join(packageDir, 'coverage', 'lcov-report');
  if (!fs.existsSync(coverageDir) || !fs.lstatSync(coverageDir).isDirectory()) continue;
  const targetDir = path.join(coverageIndexDir, packageName);
  fs.copySync(coverageDir, targetDir, { recursive: true });
}
