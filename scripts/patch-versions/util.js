const fs = require('fs');
const path = require("path");

const getDirsFromPath = (dirsPath) => fs.readdirSync(dirsPath).filter(dirName => isDirectory(dirsPath, dirName)).map(dirName => path.resolve(dirsPath, dirName));

const isDirectory = (dirPath, fileOrDirName) => fs.statSync(path.join(dirPath, fileOrDirName)).isDirectory();

const hasPackageJSONFile = (dirPath) => fs.existsSync(path.join(dirPath, 'package.json'));

const readFile = (file) => JSON.parse(fs.readFileSync(file, 'utf-8'));

const getPackageDirectories = (packagesDir) => getDirsFromPath(packagesDir).filter(dir => hasPackageJSONFile(dir))

const getPackagesVersions = (packageDirs, packageFileName) =>
    packageDirs.reduce((acc, dir) => {
        const packageFile = path.resolve(dir, packageFileName);
        const package = readFile(packageFile, 'utf-8');
        return { ...acc, [package.name]: package.version };
    }, {});

const updatePackageJson = (filesData, packageVersionsMap) => {
    const { packageJsonPath, packageJsonData } = filesData;
    const dep = packageJsonData.dependencies || [];
    const devDep = packageJsonData.devDependencies || [];

    console.log(`Updating ${packageJsonPath}`)

    const updateVersion = (package, dependencies) => {
        if (packageVersionsMap[package]) {
            console.log(`'${package}' version updated '${dependencies[package]}' ---> ${packageVersionsMap[package]}`);
            dependencies[package] = packageVersionsMap[package]
        }
    };

    Object.keys(devDep).forEach(package => {
        updateVersion(package, devDep);
    });

    Object.keys(dep).forEach(package => {
        updateVersion(package, dep);
    });

    return { packageJsonPath, packageJsonData };
}

const savePackageJson = (packageJsonInfo) => {
    const { packageJsonPath, packageJsonData } = packageJsonInfo;
    try {
        fs.writeFileSync(packageJsonPath, JSON.stringify(packageJsonData, null, 2));
        console.log(`Changes saved on ${packageJsonPath}`);
    } catch (err) {
        console.log(`${packageJsonPath} creation error:`, err);
    }
    return packageJsonInfo;
}

module.exports = {
    updatePackageJson,
    savePackageJson,
    getPackageDirectories,
    readFile,
    getPackagesVersions
};
