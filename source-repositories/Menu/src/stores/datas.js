import { defineStore } from 'pinia'
import { useMenuStore } from './menus'

export const useDataStore = defineStore('datas', {
  state: () => ({
    showMenu: false,
    keepBackground: false,
    menuPositionRight: false,
    isQwerty: false,
    openingAnimation: true,
    showLoader: false
  }),
  actions: {
    defineShow(value) {
      this.showMenu = value
      if (this.showMenu) {
        this.keepBackground = false
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
    defineKeepBackground(value) {
      this.keepBackground = value
    },
    definePosition(value) {
      this.menuPositionRight = value == "right"
    },
    defineQwerty(value) {
      this.isQwerty = value
    },
    displayLoader(value) {
      this.showLoader = value
    },
  }
})