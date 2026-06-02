import { rmSync } from 'node:fs'
import { isAbsolute, relative, resolve } from 'node:path'
import { fileURLToPath, URL } from 'node:url'

import { defineConfig, type Plugin } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

const outDir = './../../jo_libs/nui/minigame'
const rootDir = fileURLToPath(new URL('.', import.meta.url))

function excludeBuildOutput(outDir: string, paths: string[]): Plugin {
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

// https://vite.dev/config/
export default defineConfig({
  base: './',
  plugins: [
    vue(),
    vueDevTools(),
    excludeBuildOutput(outDir, [
      'img/debug',
    ]),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  build: {
    outDir,
    emptyOutDir: true,
    assetsInlineLimit: 0,
    rollupOptions: {
      output: {
        assetFileNames: () => {
          return `assets/[name][extname]`
        },
        chunkFileNames: 'assets/[name].js',
        entryFileNames: 'assets/[name].js',
      },
    },
  },
})
