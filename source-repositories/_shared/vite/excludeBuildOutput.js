import { rmSync } from 'node:fs'
import { isAbsolute, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

export function excludeBuildOutput({ rootUrl, outDir, paths }) {
  const rootDir = fileURLToPath(rootUrl)
  const outputDir = resolve(rootDir, outDir)

  return {
    name: 'exclude-build-output',
    apply: 'build',
    closeBundle() {
      for (const path of paths) {
        const target = resolve(outputDir, path)
        const relativeTarget = relative(outputDir, target)

        if (relativeTarget.startsWith('..') || isAbsolute(relativeTarget)) {
          throw new Error(`Cannot exclude path outside build output: ${path}`)
        }

        rmSync(target, { recursive: true, force: true })
      }
    },
  }
}
