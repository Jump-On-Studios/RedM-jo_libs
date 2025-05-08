import { defineStore } from 'pinia'
import { useMenuStore } from './menus'

export const useDataStore = defineStore('datas', {
  state: () => ({
    showMenu: false,
    menuPositionRight: false,
    isQwerty: false,
    openingAnimation: true
  }),
  actions: {
    defineShow(value) {
      this.showMenu = value
      if (this.showMenu) {
        const menu = useMenuStore()
        menu.updatePreview()
      }
    },
    defineOpeningAnimation(value) {
      this.openingAnimation = value
      setTimeout(() => {
        this.openingAnimation = true
      })
    },
    definePosition(value) {
      this.menuPositionRight = value == "right"
    },
    defineQwerty(value) {
      this.isQwerty = value
    }
  }
})