import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useGroupStore = defineStore('group', () => {
  const title = ref()
  const position = ref()
  const prompts = ref([])

  function updateGroup(data) {
    title.value = data.title
    position.value = data.position
    prompts.value = data.prompts
  }

  return {
    title,
    position,
    prompts,
    updateGroup,
  }
})
