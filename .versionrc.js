const packageMap = [
  {
    filename: "packages/package.json",
    type: "json"
  },
  {
    filename: "packages/blockfrost/package.json",
    type: "json"
  },
  {
    filename: "packages/cardano-graphql-db-sync/package.json",
    type: "json"
  },
  {
    filename: "packages/cip2/package.json",
    type: "json"
  },
  {
    filename: "packages/cip30/package.json",
    type: "json"
  },
  {
    filename: "packages/core/package.json",
    type: "json"
  },
  {
    filename: "packages/golden-test-generator/package.json",
    type: "json"
  },
  {
    filename: "packages/wallet/package.json",
    type: "json"
  }
];

module.exports = {
  packageFiles: packageMap,
  bumpFiles: packageMap,
  skip: {
    commit: true,
    tag: true
  },
  "tag-prefix": ""
}