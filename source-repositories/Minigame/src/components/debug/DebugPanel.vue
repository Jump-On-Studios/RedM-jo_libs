<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from "vue";
import { hideMinigameMock, showLockpickMock } from "@/dev";

interface MockLuaMessage {
  type?: string;
  data?: unknown;
}

const lastLuaCallback = ref("No Lua callback yet");

function onMessage(event: MessageEvent<MockLuaMessage>) {
  if (event.data.type !== "jo_minigame:mockLuaCallback") return;

  lastLuaCallback.value = JSON.stringify(event.data.data, null, 2);
}

onMounted(() => {
  window.addEventListener("message", onMessage);
});

onBeforeUnmount(() => {
  window.removeEventListener("message", onMessage);
});
</script>

<template>
  <aside class="debug-panel">
    <strong>Minigame Debug</strong>
    <button type="button" @click="showLockpickMock">Show Lockpick</button>
    <button type="button" @click="hideMinigameMock">Hide Minigame</button>
    <pre>{{ lastLuaCallback }}</pre>
  </aside>
</template>

<style scoped>
.debug-panel {
  position: fixed;
  top: 16px;
  left: 16px;
  z-index: 1000;
  display: grid;
  width: 220px;
  gap: 8px;
  padding: 12px;
  border: 1px solid rgb(255 255 255 / 16%);
  border-radius: 8px;
  color: #f6f7f9;
  background: rgb(22 25 29 / 92%);
  box-shadow: 0 12px 36px rgb(0 0 0 / 35%);
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
}

strong {
  font-size: 14px;
}

button {
  min-height: 34px;
  border: 0;
  border-radius: 6px;
  color: #101418;
  background: #e8edf3;
  font: inherit;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

button:hover {
  filter: brightness(1.08);
}

pre {
  min-height: 42px;
  max-height: 140px;
  margin: 0;
  padding: 8px;
  overflow: auto;
  border-radius: 6px;
  color: #d8dee7;
  background: #0d0f12;
  font-size: 12px;
  line-height: 1.35;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>
