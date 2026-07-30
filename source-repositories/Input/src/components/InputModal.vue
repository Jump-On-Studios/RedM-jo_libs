<template>
  <!--
    The overlay is the only element allowed to use viewport units: it must cover
    the screen whatever the scale. The container below holds every px dimension
    and carries the scaling, so the whole panel keeps the proportions it was
    designed with on a 1080p viewport.
  -->
  <div class="input-overlay">
    <div v-ui-scaler="'center center'" class="input-container">
      <InputRow
        v-for="(row, rowIndex) in inputStore.rows"
        :key="rowIndex"
        :row="row"
        @submit="submitFromField"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted } from 'vue'
import InputRow from '@/components/InputRow.vue'
import { useInputStore } from '@/stores/input'

const inputStore = useInputStore()

/**
 * Set while Enter is held down, so a key repeat cannot submit the next panel
 * opened by the same interaction.
 */
let ignoreEnter = false

/** Shared gate between the field-level Enter and the global one. */
function acceptsEnter(): boolean {
  if (ignoreEnter) return false

  if (inputStore.isEnterGuarded()) {
    ignoreEnter = true
    return false
  }

  return true
}

/** Enter pressed inside a field: submits whatever buttons the panel declares. */
function submitFromField() {
  if (!acceptsEnter()) return

  inputStore.submit('Enter')
}

function onKeyDown(event: KeyboardEvent) {
  if (event.code === 'Escape') {
    event.preventDefault()
    inputStore.cancel()
    return
  }

  if (event.code !== 'Enter') return
  if (!acceptsEnter()) return
  // A focused field handles its own Enter through the submit event.
  if (document.activeElement?.tagName !== 'BODY') return
  // With buttons on screen, the player is expected to pick one.
  if (inputStore.hasButton) return

  inputStore.submit('Enter')
}

function onKeyUp(event: KeyboardEvent) {
  if (event.code === 'Enter') ignoreEnter = false
}

onMounted(() => {
  window.addEventListener('keydown', onKeyDown)
  window.addEventListener('keyup', onKeyUp)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', onKeyDown)
  window.removeEventListener('keyup', onKeyUp)
})
</script>

<style scoped>
.input-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-overlay);
}

.input-container {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: var(--gap);
  width: var(--modal-width);
  max-height: var(--modal-max-height);
  padding: var(--padding-container);
  border: var(--border);
  background-color: var(--color-background);

  /*
   * Never scrolls, and therefore never clips: a scrolling container would cut
   * off the select list and the calendar, which are positioned absolutely so
   * they overlay the rows instead of pushing them down. Tall content is handled
   * by the price options, which scroll on their own.
   */
  overflow: visible;
}
</style>
