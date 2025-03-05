<template></template>
<script setup>
import { useGroupStore } from '@/stores/group'

const groupStore = useGroupStore()

window.addEventListener('message', (event) => {
  console.log(event)
  const { type, data } = event.data

  switch (type) {
    case 'updateGroup':
      groupStore.updateGroup(data)
      break
    case 'keyDown':
      groupStore.updatePressedKeys(data.key, true)
      break
    case 'keyUp':
      groupStore.updatePressedKeys(data.key, false)
      break
  }
})
</script>
