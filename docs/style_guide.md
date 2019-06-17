# Style Guide

1. [Standard](https://standardjs.com/) code styling
2. Top level modules in `src`, excluding `src/lib`, should represent domain objects, with as little implementation detail as possible. Implementation of these domain objects belongs in `src/lib`.
3. When modeling a module of the domain, use a directory to contain the logical boundaries of the module. Domain object definitions (typically interfaces) should get a file per definition. All definitions relevant to other modules should be exported from an `index.ts` file from the module. Do not export internal concerns from the module. An easy example of this construct is `src/Cardano`
4. Domain related functions should be title case. Internal functions should be camel case.
4. Domain related folders and files should be title case (excluding `index.ts`). Files that only deal with internal concerns should be snake case.
5. No use of `default` exports, except for in `src/index.ts`.