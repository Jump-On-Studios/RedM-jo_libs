import { createReadStream, existsSync } from 'node:fs'
import { extname, isAbsolute, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

export function nuiSharedFonts({ rootUrl }) {
  const rootDir = fileURLToPath(rootUrl)
  const sharedFontsDir = resolve(rootDir, './../../jo_libs/nui/assets/fonts')

  return {
    name: 'nui-shared-fonts',
    configureServer(server) {
      server.middlewares.use('/assets/fonts', (req, res, next) => {
        const url = new URL(req.url ?? '/', 'http://localhost')
        const target = resolve(sharedFontsDir, decodeURIComponent(url.pathname.replace(/^\/+/, '')))
        const relativeTarget = relative(sharedFontsDir, target)

        if (relativeTarget.startsWith('..') || isAbsolute(relativeTarget)) {
          res.statusCode = 403
          res.end('Forbidden')
          return
        }

        if (!existsSync(target)) {
          next()
          return
        }

        res.setHeader('Content-Type', contentTypeFor(target))
        createReadStream(target).pipe(res)
      })
    },
    generateBundle(_, bundle) {
      for (const asset of Object.values(bundle)) {
        if (asset.type === 'asset' && asset.fileName.endsWith('.css') && typeof asset.source === 'string') {
          asset.source = asset.source.replace(/url\((["']?)\/assets\/fonts\//g, 'url($1../../assets/fonts/')
        }

        if (asset.type === 'asset' && asset.fileName.endsWith('.html') && typeof asset.source === 'string') {
          asset.source = asset.source.replace(/(["'])\/assets\/fonts\//g, '$1../assets/fonts/')
        }
      }
    },
  }
}

function contentTypeFor(path) {
  switch (extname(path).toLowerCase()) {
    case '.otf':
      return 'font/otf'
    case '.ttf':
      return 'font/ttf'
    case '.woff':
      return 'font/woff'
    case '.woff2':
      return 'font/woff2'
    default:
      return 'application/octet-stream'
  }
}
