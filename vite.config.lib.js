import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'
import { copyFileSync } from 'fs'

export default defineConfig({
  plugins: [
    react(),
    {
      name: 'copy-types',
      writeBundle() {
        // Copy TypeScript definitions to dist
        copyFileSync('src/index.d.ts', 'dist/index.d.ts')
      }
    }
  ],
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.js'),
      name: 'HyperSyncQueryBuilder',
      formats: ['es', 'cjs'],
      fileName: (format) => `index${format === 'es' ? '.esm' : ''}.js`
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        },
        assetFileNames: (assetInfo) => {
          if (assetInfo.name?.endsWith('.css')) return 'styles.css'
          return assetInfo.name
        }
      }
    },
    cssCodeSplit: false,
    outDir: 'dist',
    emptyOutDir: true
  },
  css: {
    postcss: {
      plugins: []
    }
  }
}) 
