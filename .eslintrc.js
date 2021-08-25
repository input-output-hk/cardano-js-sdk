module.exports = {
  "parser": "@typescript-eslint/parser",
  "extends": [
      "@atixlabs/eslint-config/configurations/node",
      "plugin:@typescript-eslint/recommended",
      "plugin:jsdoc/recommended"
  ],
  "plugins": ["jsdoc"],
  "settings": {
    "import/resolver": {
      "typescript": {}
    }
  },
  "rules": {
    "jsdoc/require-param": 0,
    "jsdoc/require-returns": 0,
    "no-unused-vars": 0,
    "linebreak-style": [
      2,
      "unix"
    ],
    "no-unused-expressions": 0,
    "no-useless-constructor": 0,
    "quotes": ["error", "single", { "avoidEscape": true }],
    "unicorn/filename-case": 0,
    "unicorn/prevent-abbreviations": 0,
    "@typescript-eslint/ban-types": 0,
    "template-tag-spacing": 0,
    "no-magic-numbers": 0,
    "camelcase": 0
  }
}