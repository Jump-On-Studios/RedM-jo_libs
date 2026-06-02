import type { Plugin } from 'vite'

export function nuiSharedFonts(options: {
  rootUrl: URL
  outDir: string
  excludePaths?: string[]
}): Plugin
