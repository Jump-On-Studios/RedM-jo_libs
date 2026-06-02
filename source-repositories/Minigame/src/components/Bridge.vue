<!-- eslint-disable vue/multi-word-component-names -->
<template><span></span></template>
<script setup lang="ts">
import { useLockpickStore } from "@/stores/lockpick";
import { useMinigamesStore, type MinigameName } from "@/stores/minigames";
import { useQteStore } from "@/stores/qte";

interface MinigameMessageData {
  game?: MinigameName;
  config?: Record<string, unknown>;
}

const minigameStore = useMinigamesStore();
const lockpickStore = useLockpickStore();
const qteStore = useQteStore();

window.addEventListener("message", (event) => {
  // console.log(event)
  const { type, data } = event.data as {
    type?: string;
    data?: MinigameMessageData;
  };

  switch (type) {
    case "jo_minigame:show":
      if (data?.game === "lockpick") {
        lockpickStore.setConfig(data.config || {});
        minigameStore.show("lockpick");
      } else if (data?.game === "qte") {
        qteStore.setConfig(data.config || {});
        minigameStore.show("qte");
      }
      break;
    case "jo_minigame:hide":
      minigameStore.hide();
      lockpickStore.reset();
      qteStore.reset();
      break;
  }
});
</script>
