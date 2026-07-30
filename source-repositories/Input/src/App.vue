<template>
  <Bridge />
  <component :is="DevComponent" v-if="DevComponent" />
  <InputModal v-if="inputStore.visible" />
</template>

<script setup lang="ts">
import { defineAsyncComponent } from 'vue'
import Bridge from '@/components/Bridge.vue'
import InputModal from '@/components/InputModal.vue'
import { useInputStore } from '@/stores/input'

// Statically false in production, so the debug panel and its fixtures are
// dropped from the bundle instead of shipping with the resource.
const DevComponent = import.meta.env.DEV
  ? defineAsyncComponent(() => import('@/components/debug/DevComponent.vue'))
  : null

const inputStore = useInputStore()
</script>
