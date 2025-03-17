<template><span></span></template>
<script setup>
import { useGroupStore } from '@/stores/group'

const groupStore = useGroupStore()

window.addEventListener('message', (event) => {
  // console.log(event)
  const { type, data } = event.data

  switch (type) {
    case 'setGroup':
      groupStore.setGroup(data)
      break
    case 'keyDown':
      // console.log(type, data)
      groupStore.updatePressedKeys(data.key, true)
      break
    case 'keyUp':
      // console.log(type, data)
      groupStore.updatePressedKeys(data.key, false)
      break
    case 'nextPage':
      groupStore.nextPage()
      break
    case 'updatePrompt':
      groupStore.updatePrompt(data)
      break
    case 'updateGroup':
      groupStore.updateGroup(data)
      break
  }
})
</script>
