import { useLangStore } from '@/stores/lang';
import { watchEffect } from 'vue';
/** Replaces an element's content with its current language string. */
export const i18n = {
    beforeMount(el, binding) {
        const key = binding.value;
        const defaultContent = el.innerHTML;
        el._i18nKey = key;
        el._i18nDefault = defaultContent;
        const stopHandle = watchEffect(() => {
            const langStore = useLangStore();
            el.innerHTML = langStore.getString(key, defaultContent);
        });
        el._i18nStopHandle = stopHandle;
    },
    updated(el, binding) {
        if (el._i18nKey === binding.value)
            return;
        el._i18nKey = binding.value;
        el._i18nStopHandle?.();
        const stopHandle = watchEffect(() => {
            const langStore = useLangStore();
            el.innerHTML = langStore.getString(binding.value, el._i18nDefault || '');
        });
        el._i18nStopHandle = stopHandle;
    },
    unmounted(el) {
        el._i18nStopHandle?.();
    },
};
