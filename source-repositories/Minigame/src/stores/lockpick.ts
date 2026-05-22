import { defineStore } from "pinia";

interface LockpickState {
  config: Record<string, unknown>;
}

export const useLockpickStore = defineStore("lockpick", {
  state: (): LockpickState => ({
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
