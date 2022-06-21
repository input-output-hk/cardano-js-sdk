module.exports = {
    coveragePathIgnorePatterns: ['.config.js'],
    preset: 'ts-jest',
    setupFiles: ['dotenv/config'],
    testTimeout: process.env.CI ? 120000 : 12000,
    transform: {
        '^.+\\.test.ts?$': 'ts-jest'
    }
};