module.exports = {
    coveragePathIgnorePatterns: ['.config.js'],
    preset: 'ts-jest',
    transform: {
        '^.+\\.test.ts?$': 'ts-jest'
    }
};