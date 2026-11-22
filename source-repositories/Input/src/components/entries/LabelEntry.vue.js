import { useEntryStyle } from '@/composables/useEntryStyle';
const { defineProps, } = {};
const props = defineProps();
const style = useEntryStyle(() => props.entry);
const __VLS_ctx = {
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
    __VLS_asFunctionalElement1(__VLS_intrinsics.label)({
        ...{ class: "entry-label" },
        ...{ class: (__VLS_ctx.entry.class) },
        ...{ style: (__VLS_unwrap(style, {})) },
        for: (__VLS_ctx.entry.target),
    });
    const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vHtml, {});
    __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.entry.value), }, ...__VLS_directiveHookArgsRest(__VLS_0));
    /** @type {__VLS_StyleScopedClasses['entry-label']} */ ;
    // @ts-ignore
    [entry, entry, entry, style,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeProps: {},
});
export default {};
