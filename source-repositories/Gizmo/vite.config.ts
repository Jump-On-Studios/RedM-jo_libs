import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  base: "./",
  plugins: [react()],
  build: {
    outDir: './../../jo_libs/nui/gizmo',
    emptyOutDir: true,
    chunkSizeWarningLimit: 800,
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
