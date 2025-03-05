
import { defineStore } from 'pinia'


export const useGroupStore = defineStore('group', {
  state: () => ({
    title: undefined,
    position: "bottom-right",
    prompts: [],
    pressedKeys: {}
  }),
  actions: {
    // since we rely on `this`, we cannot use an arrow function
    updateGroup(data) {
      this.title = data.title
      this.position = data.position
      this.prompts = data.prompts
    },
    updatePressedKeys(key, value) {

      if (!value) {
        delete this.pressedKeys[key];
      }
      else {
        this.pressedKeys[key] = value
      }
      console.log(this.pressedKeys);
    }
  },
})


