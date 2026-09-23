import { defineStore } from 'pinia'

export const useGroupStore = defineStore('group', {
  state: () => ({
    id: undefined,
    title: undefined,
    position: 'bottom-right',
    prompts: [],
    pressedKeys: {},
    currentPageIndex: 0,
    nextPageKey: 'A',
    forcedHide: false,
  }),
  actions: {
    // since we rely on `this`, we cannot use an arrow function
    setGroup(data) {
      // a new group must not inherit the keys pressed on the previous one
      if (data.id !== this.id) this.pressedKeys = {}
      this.id = data.id
      this.title = data.title
      this.position = data.position
      this.prompts = data.prompts
      this.nextPageKey = data.nextPageKey
      this.currentPageIndex = data.currentPage ? data.currentPage - 1 : 0
    },
    updatePressedKeys(key, value) {
      if (!value) {
        delete this.pressedKeys[key]
      } else {
        this.pressedKeys[key] = value
      }
      // console.log(this.pressedKeys);
    },

    nextPage() {
      if (this.prompts[this.currentPageIndex + 1] !== undefined) {
        this.currentPageIndex++
      } else {
        this.currentPageIndex = 0
      }
      this.pressedKeys = {}
    },

    updatePrompt(data) {
      const page = data.page - 1 // Lua is 1 indexed
      const position = data.position - 1 // Lua is 1 indexed
      const prompt = this.prompts[page]?.[position]
      if (!prompt) return
      prompt[data.property] = data.value
    },

    updateGroup(data) {
      this[data.property] = data.value
    },

    forceHide(value) {
      this.forcedHide = value
    },
  },
})
