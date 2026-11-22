import { onBeforeUnmount } from 'vue';
import { useInputStore } from '@/stores/input';
import { useLangStore } from '@/stores/lang';
const inputStore = useInputStore();
const langStore = useLangStore();
function stringRecord(value) {
    if (!value || typeof value !== 'object' || Array.isArray(value))
        return null;
    const entries = Object.entries(value);
    if (entries.some(([, item]) => typeof item !== 'string'))
        return null;
    return Object.fromEntries(entries);
}
/**
 * Single entry point for the messages sent by SendNUIMessage on the Lua side.
 * The payload shape `{ event, data }` is part of the contract with
 * jo_libs/modules/input/client.lua and must not change.
 */
function onMessage(message) {
    const { event, data } = (message.data ?? {});
    switch (event) {
        case 'newInput':
            inputStore.open(data);
            break;
        case 'setStrings':
        case 'setLanguage': {
            const payload = data;
            const strings = payload && typeof payload === 'object' && 'strings' in payload
                ? stringRecord(payload.strings)
                : stringRecord(payload);
            if (strings)
                langStore.setStrings(strings);
            break;
        }
    }
}
window.addEventListener('message', onMessage);
onBeforeUnmount(() => {
    window.removeEventListener('message', onMessage);
});
const __VLS_ctx = {};
let __VLS_components;
let __VLS_intrinsics;
let __VLS_directives;
void __VLS_ctx, __VLS_components, __VLS_intrinsics, __VLS_directives;
const __VLS_template = () => {
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({});
export default {};
