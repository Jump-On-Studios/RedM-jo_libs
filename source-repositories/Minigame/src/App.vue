<script setup lang="ts">
import Bridge from "@/components/Bridge.vue";
import LockpickGame from "@/components/minigames/LockpickGame.vue";
import { useMinigamesStore } from "@/stores/minigames";

const minigameStore = useMinigamesStore();
</script>

<template>
  <Bridge />
  <LockpickGame v-if="minigameStore.activeGame === 'lockpick'" />
</template>

<style scoped></style>
