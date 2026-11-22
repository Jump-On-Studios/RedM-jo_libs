import { useTemplateRef } from 'vue';
import { useAutofocus } from '@/composables/useAutofocus';
import { useEntryStyle } from '@/composables/useEntryStyle';
import { useEntryValue } from '@/composables/useEntryValue';
import { useInputStore } from '@/stores/input';
const { defineProps, defineEmits, } = {};
const props = defineProps();
const emit = defineEmits();
const field = useTemplateRef('field');
const style = useEntryStyle(() => props.entry);
const { value, hasError } = useEntryValue(() => props.entry);
useAutofocus(() => props.entry.id, () => field.value);
const inputStore = useInputStore();
/**
 * Set once this field sees a fresh Enter press. Until then, key repeats come
 * from an Enter still held since the previous panel and are swallowed, as is
 * any Enter inside the open guard, so they cannot fill the box with new lines.
 */
let freshEnter = false;
function onEnter(event) {
    if (event.ctrlKey) {
        event.preventDefault();
        emit('submit');
        return;
    }
    if (inputStore.isEnterGuarded()) {
        event.preventDefault();
        return;
    }
    if (!event.repeat)
        freshEnter = true;
    else if (!freshEnter)
        event.preventDefault();
}
const __VLS_ctx = {
    ...{},
    ...{},
    ...{},
    ...{},
};
let __VLS_components;
let __VLS_intrinsics;
let __VLS_directives;
void __VLS_ctx, __VLS_components, __VLS_intrinsics, __VLS_directives;
const __VLS_template = () => {
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
        ...{ class: "entry-field entry-field--textarea" },
        ...{ class: ([__VLS_ctx.entry.class, { error: __VLS_unwrap(hasError, {}) }]) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-field']} */ ;
    /** @type {__VLS_StyleScopedClasses['entry-field--textarea']} */ ;
    /** @type {__VLS_StyleScopedClasses['error']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.textarea)({
        ...{ onKeydown: (onEnter) },
        id: (__VLS_ctx.entry.id),
        ref: "field",
        value: (__VLS_unwrap(value, {})),
        ...{ class: "entry-field__control entry-field__textarea" },
        placeholder: (__VLS_ctx.entry.placeholder),
        rows: (__VLS_ctx.entry.rows ?? 4),
        maxlength: (__VLS_ctx.entry.maxLength),
    });
    /** @type {__VLS_StyleScopedClasses['entry-field__control']} */ ;
    /** @type {__VLS_StyleScopedClasses['entry-field__textarea']} */ ;
    // @ts-ignore
    [entry, entry, entry, entry, entry, hasError, style, value,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeEmits: {},
    __typeProps: {},
});
export default {};
