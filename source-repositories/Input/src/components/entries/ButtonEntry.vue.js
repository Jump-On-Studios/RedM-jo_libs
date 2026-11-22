import { useEntryStyle } from '@/composables/useEntryStyle';
import { useInputStore } from '@/stores/input';
const { defineProps, } = {};
const props = defineProps();
const inputStore = useInputStore();
const style = useEntryStyle(() => props.entry);
function onClick() {
    inputStore.submit(props.entry.id, props.entry.ignoreRequired);
}
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
    __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
        ...{ onClick: (onClick) },
        type: "button",
        ...{ class: "entry-button" },
        ...{ class: (__VLS_ctx.entry.class) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-button']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "entry-button__content" },
    });
    /** @type {__VLS_StyleScopedClasses['entry-button__content']} */ ;
    if (__VLS_ctx.entry.icon) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.img)({
            ...{ class: "entry-button__icon" },
            src: (__VLS_ctx.entry.icon),
            alt: "",
            'aria-hidden': "true",
        });
        /** @type {__VLS_StyleScopedClasses['entry-button__icon']} */ ;
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.span)({
        ...{ class: "entry-button__label" },
    });
    const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vHtml, {});
    __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: (__VLS_ctx.entry.value), }, ...__VLS_directiveHookArgsRest(__VLS_0));
    /** @type {__VLS_StyleScopedClasses['entry-button__label']} */ ;
    // @ts-ignore
    [entry, entry, entry, entry, style,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeProps: {},
});
export default {};
