import { defineStore } from "pinia";

interface LangState {
  strings: Record<string, string>;
}

export const useLangStore = defineStore("lang", {
  state: (): LangState => ({
    strings: {},
  }),
  actions: {
    setStrings(strings: Record<string, string>) {
      this.strings = strings;
    },

    getString(key: string, fallback = "") {
      return this.strings[key] || fallback;
    },
  },
});
