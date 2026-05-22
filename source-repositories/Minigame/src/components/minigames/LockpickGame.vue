<script setup lang="ts">
import { computed } from "vue";
import { sendToLua } from "@/helpers/luaHelper";
import { useLockpickStore } from "@/stores/lockpick";
import { useMinigamesStore } from "@/stores/minigames";

const minigameStore = useMinigamesStore();
const lockpickStore = useLockpickStore();

const formattedConfig = computed(() =>
  JSON.stringify(lockpickStore.config, null, 2),
);

async function finish(success: boolean) {
  await sendToLua("jo_minigame:finished", { success });
  minigameStore.hide();
  lockpickStore.reset();
}
</script>

<template>
  <main class="lockpick-game">
    <section class="lockpick-panel">
      <h1>Lockpick</h1>
      <pre>{{ formattedConfig }}</pre>
      <div class="actions">
        <button class="success" type="button" @click="finish(true)">Success</button>
        <button class="failure" type="button" @click="finish(false)">Failure</button>
      </div>
    </section>
  </main>
</template>

<style scoped>
.lockpick-game {
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
  color: #f7f3ea;
  background: rgb(12 13 15 / 66%);
}

.lockpick-panel {
  width: min(420px, calc(100vw - 32px));
  padding: 24px;
  border: 1px solid rgb(255 255 255 / 16%);
  border-radius: 8px;
  background: #16191d;
  box-shadow: 0 18px 50px rgb(0 0 0 / 35%);
}

h1 {
  margin: 0 0 16px;
  font-size: 26px;
  font-weight: 700;
  line-height: 1.1;
}

pre {
  min-height: 90px;
  max-height: 220px;
  margin: 0 0 18px;
  padding: 12px;
  overflow: auto;
  border: 1px solid rgb(255 255 255 / 10%);
  border-radius: 6px;
  color: #d8dee7;
  background: #0d0f12;
  font-size: 13px;
  line-height: 1.45;
  white-space: pre-wrap;
  word-break: break-word;
}

.actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

button {
  min-height: 42px;
  border: 0;
  border-radius: 6px;
  color: #ffffff;
  font: inherit;
  font-weight: 700;
  cursor: pointer;
}

button:hover {
  filter: brightness(1.08);
}

.success {
  background: #238653;
}

.failure {
  background: #9d2f35;
}
</style>
