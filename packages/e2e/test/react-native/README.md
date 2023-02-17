## Getting Started

First, run the development server:

```bash
yarn start
```

### iOS

```bash
yarn pod-install
yarn ios
```

### Android

```bash
yarn android
```

## E2E tests with Detox

### Environment setup
See: [Detox - Environment Setup](https://wix.github.io/Detox/docs/introduction/getting-started)

### Device configs
See: [Detox - Device Configs](https://wix.github.io/Detox/docs/introduction/project-setup#step-3-device-configs)

### Run tests with Detox in debug mode
Android:
```bash
yarn start
yarn detox:build:android-debug
yarn detox:e2e:android-debug
```

iOS:
```bash
yarn pod-install
yarn start
yarn detox:build:ios-debug
yarn detox:e2e:ios-debug
```

### Run tests with Detox in release mode
Android:
```bash
yarn detox:build:android-release
yarn detox:e2e:android-release
```

iOS:
```bash
yarn pod-install
yarn detox:build:ios-release
yarn detox:e2e:ios-release
```

### Reports

Allure requires Java 8 or higher

Run web server and serve Allure report in default web browser (useful for local development)
```bash
yarn serve-allure-report
```

Generate static Allure report (useful for CI)
```bash
yarn generate-allure-report
```

Issues with Allure

https://github.com/wix-incubator/jest-allure2-reporter/issues/5
