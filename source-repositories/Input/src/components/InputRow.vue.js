import { ENTRY_COMPONENTS } from "@/components/entries";
const { defineProps, defineEmits, } = {};
const __VLS_props = defineProps();
const emit = defineEmits();
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
    __VLS_withDotValue(ENTRY_COMPONENTS, {});
    void {};
    /** @type {__VLS_StyleScopedClasses['entry-label']} */ ;
    /** @type {__VLS_StyleScopedClasses['entry-label']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "input-row" },
    });
    /** @type {__VLS_StyleScopedClasses['input-row']} */ ;
    const __VLS_0 = __VLS_tryAsConstant((__VLS_ctx.row.columns));
    for (const [entry] of __VLS_vFor(__VLS_nonNull(__VLS_0))) {
        const __VLS_1 = (ENTRY_COMPONENTS.value[entry.type]);
        // @ts-ignore
        const __VLS_2 = __VLS_asFunctionalComponent1(__VLS_1, new __VLS_1({
            // @ts-ignore
            ...{ 'onSubmit': {} }, key: (entry.id), entry: (entry),
        }));
        const __VLS_3 = __VLS_2({
            ...{ 'onSubmit': {} },
            key: (entry.id),
            entry: (entry),
        }, ...__VLS_functionalComponentArgsRest(__VLS_2));
        let __VLS_6;
        const __VLS_7 = {
            /** @type {typeof __VLS_6.submit} */
            onSubmit: (...[$event]) => {
                void $event;
                return (__VLS_unwrap(emit, {})('submit'));
                // @ts-ignore
                [row, ENTRY_COMPONENTS, emit,];
            },
        };
        void __VLS_7;
        var __VLS_4;
        var __VLS_5;
        // @ts-ignore
        [];
    }
    // @ts-ignore
    [];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeEmits: {},
    __typeProps: {},
});
export default {};
