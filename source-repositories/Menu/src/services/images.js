// The images of a URL loaded since the page opened by a LoadingImage: shown at once
// by the others
export const loadedImages = new Set()

// The ms an image of the web stays wanted before it is requested: scrolling fast through a menu never requests the
// images it passes (a CDN would rate limit them)
export const WEB_DELAY = 150

export function isWeb(src) {
  return /^https?:\/\//i.test(src)
}
