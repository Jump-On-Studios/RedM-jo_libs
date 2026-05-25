<script setup lang="ts">
import { computed } from "vue";
import { sendToLua } from "@/helpers/luaHelper";
import { useMinigamesStore } from "@/stores/minigames";
import { useQteStore } from "@/stores/qte";

const minigameStore = useMinigamesStore();
const qteStore = useQteStore();

const formattedConfig = computed(() => JSON.stringify(qteStore.config, null, 2));

async function finish(success: boolean) {
  await sendToLua("jo_minigame:finished", {
    game: "qte",
    success,
  });

  minigameStore.hide();
  qteStore.reset();
}
</script>

<template>
  <main class="qte-game">
    <section class="qte-panel">
      <h1>QTE</h1>
      <pre>{{ formattedConfig }}</pre>
      <div class="actions">
        <button class="success" type="button" @click="finish(true)">Success</button>
        <button class="failure" type="button" @click="finish(false)">Failure</button>
      </div>
    </section>
  </main>
</template>

<style scoped>
.qte-game {
  position: fixed;
  inset: 0;
  z-index: 20;
  display: grid;
  place-items: center;
  color: #f7f3ea;
  background: rgb(12 13 15 / 66%);
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
}

.qte-panel {
  width: 420px;
  padding: 24px;
  border: 1px solid rgb(255 255 255 / 16%);
  border-radius: 8px;
  background: #16191d;
  box-shadow: 0 18px 50px rgb(0 0 0 / 35%);
}

h1 {
  margin: 0 0 16px;
  font-size: 26px;
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

.success {
  background: #238653;
}

.failure {
  background: #9d2f35;
}
</style>
