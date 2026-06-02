import type { Plugin } from 'vite'

export function excludeBuildOutput(options: {
  rootUrl: URL
  outDir: string
  paths: string[]
}): Plugin
