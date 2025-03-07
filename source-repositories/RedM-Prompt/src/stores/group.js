
import { defineStore } from 'pinia'


export const useGroupStore = defineStore('group', {
  state: () => ({
    title: undefined,
    position: "bottom-right",
    prompts: [],
    pressedKeys: {},
    currentPageIndex: 0,
    nextPageKey: "A"
  }),
  actions: {
    // since we rely on `this`, we cannot use an arrow function
    updateGroup(data) {
      this.title = data.title
      this.position = data.position
      this.prompts = data.prompts
      this.nextPageKey = data.nextPageKey;
      this.currentPageIndex = data.currentPage ? data.currentPage - 1 : 0;
    },
    updatePressedKeys(key, value) {

      if (!value) {
        delete this.pressedKeys[key];
      }
      else {
        this.pressedKeys[key] = value
      }
      console.log(this.pressedKeys);
    },

    nextPage() {
      if (this.prompts[this.currentPageIndex + 1] !== undefined) {
        this.currentPageIndex++;
      } else {
        this.currentPageIndex = 0;
      }
      this.pressedKeys = {}
    }

  },
})


