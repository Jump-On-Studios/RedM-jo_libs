import { useTemplateRef } from 'vue';
import { useAutofocus } from '@/composables/useAutofocus';
import { useEntryStyle } from '@/composables/useEntryStyle';
import { useEntryValue } from '@/composables/useEntryValue';
const { defineProps, defineEmits, } = {};
const props = defineProps();
const emit = defineEmits();
const field = useTemplateRef('field');
const style = useEntryStyle(() => props.entry);
const { value, hasError } = useEntryValue(() => props.entry);
useAutofocus(() => props.entry.id, () => field.value);
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
    __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
        ...{ class: "entry-field" },
        ...{ class: ([__VLS_ctx.entry.class, { error: __VLS_unwrap(hasError, {}) }]) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-field']} */ ;
    /** @type {__VLS_StyleScopedClasses['error']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.input)({
        ...{ onKeydown: (...[$event]) => {
                void $event;
                return (__VLS_unwrap(emit, {})('submit'));
                // @ts-ignore
                [entry, hasError, style, emit,];
            } },
        id: (__VLS_ctx.entry.id),
        ref: "field",
        value: (__VLS_unwrap(value, {})),
        type: "text",
        ...{ class: "entry-field__control" },
        placeholder: (__VLS_ctx.entry.placeholder),
    });
    /** @type {__VLS_StyleScopedClasses['entry-field__control']} */ ;
    // @ts-ignore
    [entry, entry, value,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeEmits: {},
    __typeProps: {},
});
export default {};
