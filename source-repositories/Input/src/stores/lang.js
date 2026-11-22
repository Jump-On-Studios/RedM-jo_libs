import { defineStore } from 'pinia';
export const useLangStore = defineStore('lang', {
    state: () => ({
        strings: {},
    }),
    actions: {
        setStrings(strings) {
            this.strings = strings;
        },
        getString(key, fallback = '') {
            return this.strings[key] || fallback;
        },
    },
});
