import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useGroupStore = defineStore('group', () => {
  const title = ref('Stable Shop')
  const position = ref('bottom-left')
  const prompts = ref([
    {
      label: 'Press Prompt',
      keyboardKeys: ['E'],
    },
    {
      label: 'Multi press Prompt',
      keyboardKeys: ['F', 'A'],
    },
    {
      label: 'Hold Prompt',
      keyboardKeys: ['SPACE'],
      holdTime: 1000,
    },
  ])

  // const doubleCount = computed(() => count.value * 2)
  // function increment() {
  //   count.value++
  // }

  return { title, prompts, position }
})
