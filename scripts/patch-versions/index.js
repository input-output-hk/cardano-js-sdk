// Usage: node scripts/patch-versions/index.js

const path = require("path");
const { updatePackageJson, savePackageJson, getPackageDirectories, readFile, getPackagesVersions } = require("./util");

// Directory on main root directory with is the root of the packages (workspace)
const PACKAGES_DIR_NAME = process.env.PACKAGES_DIR_NAME || 'packages'

// Update PACKAGE_FILE (package.json) permanently.
const PACKAGE_FILE = process.env.PACKAGE_FILE || 'package.json';

const ROOT_PROJECT_DIR = path.resolve(process.cwd(), "");
const PACKAGES_DIR = path.resolve(ROOT_PROJECT_DIR, PACKAGES_DIR_NAME);
const LOG_SEPARATOR = Array.from({ length: 60 }).join('-');

/**
 * Checks every package.json file (dependencies and devDependencies) and patch the version of each sibling dependency
 * Extract package versions from the corresponding package.json["version"]
 * The main purpose is to be used in CI/CD right before NPM publishing process
 */
(() => {
  const packagesDirs = getPackageDirectories(PACKAGES_DIR);
  console.log('Packages directories: ', packagesDirs)

  const packagesVersions = getPackagesVersions(packagesDirs, PACKAGE_FILE);
  console.log('The most recent packages versions: ', packagesVersions);

  for (const dir of packagesDirs) {
    const packageJsonPath = path.resolve(dir, PACKAGE_FILE);
    const packageJsonData = readFile(packageJsonPath);
    const updatedPackageJSON = updatePackageJson({ packageJsonPath, packageJsonData }, packagesVersions);
    savePackageJson(updatedPackageJSON);
    console.log(LOG_SEPARATOR);
  }
})();