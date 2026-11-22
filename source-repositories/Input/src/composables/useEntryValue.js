import { computed, toValue } from 'vue';
import { useInputStore } from '@/stores/input';
/**
 * Binds an entry component to its slot in the store, so every input type stays
 * self-contained instead of receiving its value through the row.
 */
export function useEntryValue(entry) {
    const inputStore = useInputStore();
    const value = computed({
        get: () => inputStore.values[toValue(entry).id],
        set: (next) => inputStore.setValue(toValue(entry).id, next),
    });
    const hasError = computed(() => inputStore.errors[toValue(entry).id] === true);
    return { value, hasError };
}
