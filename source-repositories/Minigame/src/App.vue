<script setup lang="ts">
import Bridge from "@/components/Bridge.vue";
import DevComponent from "@/components/debug/DevComponent.vue";
import LockpickGame from "@/components/minigames/LockpickGame.vue";
import { useMinigamesStore } from "@/stores/minigames";

const isDev = import.meta.env.DEV;
const minigameStore = useMinigamesStore();
</script>

<template>
  <Bridge />
  <DevComponent v-if="isDev" />
  <LockpickGame v-if="minigameStore.activeGame === 'lockpick'" />
</template>

<style scoped></style>
