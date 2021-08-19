module.exports = {
  "parser": "@typescript-eslint/parser",
  "extends": [
      "@atixlabs/eslint-config/configurations/node",
      "plugin:@typescript-eslint/recommended"
  ],
  "settings": {
    "import/resolver": {
      "typescript": {}
    }
  },
  "rules": {
    "no-unused-vars": 0,
    "linebreak-style": [
      2,
      "unix"
    ],
    "no-unused-expressions": 0,
    "no-useless-constructor": 0,
    "quotes": ["error", "single", { "avoidEscape": true }],
    "unicorn/filename-case": 0,
    "@typescript-eslint/ban-types": 0
  }
}