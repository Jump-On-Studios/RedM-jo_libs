<template>
  <img v-if="shown != null" :src="shown" :class="props.class" />
  <div v-else class="image-loading">
    <img class="spinner" src="/assets/images/menu/loading.gif" />
  </div>
</template>

<script setup>
import { inject, onBeforeUnmount, ref, watch } from 'vue'
import { isWeb, loadedImages, WEB_DELAY } from '../../services/images'
const API = inject('API')

// An image of a URL (a CDN, another resource) shows the loading spinner of the menu until it is loaded; the menu's own
// images, and an image already in the browser's cache, are there at once. When the image changes, the former one stays
// until the new one is loaded: no spinner between two images.
// An image of the web (http, https) is requested only once it stays wanted WEB_DELAY ms, its request cancelled when it
// changes or leaves the menu: scrolling fast through a menu never requests the images it passes (a CDN would rate limit
// them). One that fails (a CDN's rate limit) is requested again RETRIES times, RETRY_DELAY ms apart.
const props = defineProps(['src', 'class'])

const RETRIES = 2
const RETRY_DELAY = 3000

const shown = ref(null)
let timer = null
let pending = null

function cancel() {
  clearTimeout(timer)
  timer = null
  if (!pending) return
  pending.onload = pending.onerror = null
  pending.src = '' // stops its request
  pending = null
}

function request(src, retries) {
  const image = new Image()
  image.src = src
  // already in the browser's cache: no spinner
  if (image.complete && image.naturalWidth > 0) {
    loadedImages.add(src)
    shown.value = src
    return
  }
  pending = image
  image.onload = () => {
    pending = null
    loadedImages.add(src)
    shown.value = src
  }
  image.onerror = () => {
    pending = null
    if (retries > 0 && isWeb(src)) {
      timer = setTimeout(() => request(src, retries - 1), RETRY_DELAY)
    } else {
      shown.value = src
    }
  }
}

function load(src) {
  cancel()
  if (!API.isNUIImage(src) || loadedImages.has(src)) {
    shown.value = src || ''
    return
  }
  if (isWeb(src)) {
    timer = setTimeout(() => request(src, RETRIES), WEB_DELAY)
  } else {
    request(src, 0)
  }
}

watch(() => props.src, load, { immediate: true })
onBeforeUnmount(cancel)
</script>

<style scoped lang="scss">
.image-loading {
  display: flex;
  width: 100%;
  height: 100%;
  justify-content: center;
  align-items: center;

  img.spinner {
    width: 50%;
    opacity: 0.5;
    aspect-ratio: auto;
    object-fit: contain;
  }
}
</style>
