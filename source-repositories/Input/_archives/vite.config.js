import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'
import { nuiSharedFonts } from '../_shared/vite/nuiSharedFonts.js'

const outDir = './../../jo_libs/nui/input'

// https://vite.dev/config/
export default defineConfig({
  base: './',
  plugins: [
    vue(),
    vueDevTools(),
    nuiSharedFonts({
      rootUrl: new URL('.', import.meta.url),
    }),
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
