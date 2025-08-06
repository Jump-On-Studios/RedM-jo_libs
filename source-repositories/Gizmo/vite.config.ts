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
        manualChunks(id) {
          if (id.indexOf('node_modules') >= 0) {
            if (id.indexOf('@react-three') >= 0) {
              return 'index-react-three';
            }
            if (id.indexOf('three') >= 0) {
              return 'index-threejs';
            }
            if (id.indexOf('react') >= 0 || id.indexOf('react-dom') >= 0) {
              return 'index-react';
            }
            return 'index';
          }
        },
      },
    },
  },
})
