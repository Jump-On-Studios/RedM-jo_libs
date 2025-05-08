import { defineStore } from 'pinia'

export const useLangStore = defineStore('langs', {
  state: () => ({
    strings: {
      bigTitle: 'Menu',
      headerTitle: 'Menu',
      color: 'Color',
      of: '%1 of %2',
      selection: "Selection",
      buy: "Buy",
      back: "Back",
      select: "Select",
      price: 'Price',
      devise: '$',
      number: 'Number %1',
      free: 'Free',
      variation: 'Variation',
    }
  }),
  getters: {
    lang: ({ strings }) => (index) => strings[index]?strings[index]:('#'+index),
  },
  actions: {
    updateStrings(value) {
      this.strings = {...this.strings,...value}
    }
  }
})