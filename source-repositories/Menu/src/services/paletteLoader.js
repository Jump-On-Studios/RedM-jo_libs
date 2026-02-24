const paletteCache = new Map();
const warnedPalettes = new Set();

function toHex(value) {
  return value.toString(16).padStart(2, "0");
}

function rgbToHex(r, g, b) {
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
}

function warnOnce(paletteName, error) {
  if (warnedPalettes.has(paletteName)) return;
  warnedPalettes.add(paletteName);
  console.warn(
    `[paletteLoader] Failed to load palette "${paletteName}"`,
    error,
  );
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.decoding = "async";
    image.onload = () => resolve(image);
    image.onerror = () => reject(new Error(`Unable to load image: ${src}`));
    image.src = src;
  });
}

function getColorsFromImage(image) {
  const width = image.naturalWidth || image.width;
  const height = image.naturalHeight || image.height;

  if (!width || !height) return [];

  const canvas = document.createElement("canvas");
  canvas.width = width;
  canvas.height = height;

  const context = canvas.getContext("2d", { willReadFrequently: true });
  if (!context) return [];

  context.drawImage(image, 0, 0);
  const pixels = context.getImageData(0, 0, width, height).data;
  const rowOffset = Math.floor((height - 1) / 2) * width * 4;
  const colors = [];

  for (let x = 0; x < width; x++) {
    const offset = rowOffset + x * 4;
    colors.push(
      rgbToHex(pixels[offset], pixels[offset + 1], pixels[offset + 2]),
    );
  }

  return colors;
}

async function loadPaletteColors(paletteName) {
  if (
    !paletteName ||
    typeof window === "undefined" ||
    typeof document === "undefined"
  ) {
    return [];
  }

  const src = `./assets/images/palettes/${paletteName}.png`;
  const image = await loadImage(src);
  return getColorsFromImage(image);
}

export function getPaletteColors(paletteName) {
  if (!paletteName) return Promise.resolve([]);

  if (!paletteCache.has(paletteName)) {
    const request = loadPaletteColors(paletteName).catch((error) => {
      warnOnce(paletteName, error);
      return [];
    });
    paletteCache.set(paletteName, request);
  }

  return paletteCache.get(paletteName);
}

export function clearPaletteCache() {
  paletteCache.clear();
  warnedPalettes.clear();
}
