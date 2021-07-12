# Golden Test Generator
Generate golden test files for a range of Cardano concepts, for the purpose of comparing results 
with application state during integration tests. The intended interface is the CLI, but the 
module is structured to offer access as libraries.

## Download or Build
Builds are attached as artifacts from the GitHub workflow runs, otherwise run

``` console
yarn pkg
```

## Run
```console
./build/golden-test-generator-{ linux | macos } --help
```
