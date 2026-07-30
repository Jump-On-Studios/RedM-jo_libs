<template>
  <aside class="debug-panel" :class="{ 'is-collapsed': collapsed }">
    <header class="debug-panel__header" @click="toggle">
      <span>jo_input — debug</span>
      <span>{{ collapsed ? '+' : '−' }}</span>
    </header>

    <div v-if="!collapsed" class="debug-panel__body">
      <div class="debug-panel__scenarios">
        <button
          v-for="scenario in scenarios"
          :key="scenario.id"
          type="button"
          class="debug-panel__button"
          @click="scenario.run()"
        >
          {{ scenario.label }}
        </button>
      </div>

      <div class="debug-panel__output">
        <div class="debug-panel__label">Last call to Lua</div>
        <pre v-if="lastCall">{{ lastCall }}</pre>
        <p v-else class="debug-panel__empty">Nothing sent yet.</p>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
import { scenarios } from '@/dev'
import { onDevLuaCall } from '@/helpers/luaHelper'

const STORAGE_KEY = 'jo_input:debug-collapsed'

const collapsed = ref(localStorage.getItem(STORAGE_KEY) === 'true')
const lastCall = ref('')

function toggle() {
  collapsed.value = !collapsed.value
  localStorage.setItem(STORAGE_KEY, String(collapsed.value))
}

const stop = onDevLuaCall((method, data) => {
  lastCall.value = `${method}\n${JSON.stringify(data, null, 2)}`
})

onBeforeUnmount(stop)
</script>

<style scoped>
.debug-panel {
  position: fixed;
  top: 12px;
  right: 12px;
  z-index: 100;
  width: 320px;
  border: 1px solid #555;
  background-color: rgba(0, 0, 0, 0.9);
  color: #fff;
  font-family: monospace;
  font-size: 12px;
}

.debug-panel__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 6px 8px;
  border-bottom: 1px solid #555;
  cursor: pointer;
}

.debug-panel.is-collapsed .debug-panel__header {
  border-bottom: none;
}

.debug-panel__body {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 8px;
}

.debug-panel__scenarios {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 4px;
}

.debug-panel__button {
  padding: 6px;
  border: 1px solid #555;
  background-color: #222;
  color: #fff;
  font-family: inherit;
  font-size: inherit;
  cursor: pointer;
}

.debug-panel__button:hover {
  background-color: #333;
}

.debug-panel__label {
  margin-bottom: 4px;
  color: #999;
}

.debug-panel__output pre {
  max-height: 260px;
  margin: 0;
  padding: 6px;
  overflow: auto;
  border: 1px solid #333;
  background-color: #111;
  user-select: text;
  white-space: pre-wrap;
  word-break: break-word;
}

.debug-panel__empty {
  color: #666;
}
</style>
