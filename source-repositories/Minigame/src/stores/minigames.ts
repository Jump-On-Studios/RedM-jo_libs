import { defineStore } from "pinia";

export type MinigameName = "lockpick" | "qte";

interface MinigamesState {
  activeGame: MinigameName | null;
}

export const useMinigamesStore = defineStore("minigames", {
  state: (): MinigamesState => ({
    activeGame: null,
  }),
  actions: {
    show(game: MinigameName) {
      this.activeGame = game;
    },

    hide() {
      this.activeGame = null;
    },
  },
});
