import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'
import { excludeBuildOutput } from '../_shared/vite/excludeBuildOutput.js'
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
    excludeBuildOutput({
      rootUrl: new URL('.', import.meta.url),
      outDir,
      paths: [
        'assets/ui',
      ],
    }),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  css: {
    preprocessorOptions: {
      scss: {
        // Makes the shared mixins available in every component without each of
        // them having to @use the partial. It defines no rule, so nothing is
        // duplicated in the output.
        additionalData: '@use "@/styles/mixins" as *;\n',
      },
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
