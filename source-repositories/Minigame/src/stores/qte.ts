import { defineStore } from "pinia";

interface QteState {
  config: Record<string, unknown>;
}

export const useQteStore = defineStore("qte", {
  state: (): QteState => ({
    config: {},
  }),
  actions: {
    setConfig(config: Record<string, unknown>) {
      this.config = config;
    },

    reset() {
      this.config = {};
    },
  },
});
