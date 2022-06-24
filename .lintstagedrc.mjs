import { ESLint } from 'eslint'

const removeIgnoredFiles = async (files) => {
  const eslint = new ESLint()
  const isIgnored = await Promise.all(
    files.map((file) =>  eslint.isPathIgnored(file))
  )
  const filteredFiles = files.filter((_, i) => !isIgnored[i])
  return filteredFiles.join(' ')
}

export default {
  "packages/!(*golden-test-generator)/**/*.{js,ts}": async (files) => {
    const filesToLint = await removeIgnoredFiles(files)
    return [`eslint --debug --max-warnings=0 ${filesToLint}`, "yarn tscNoEmit"]
  },
}
