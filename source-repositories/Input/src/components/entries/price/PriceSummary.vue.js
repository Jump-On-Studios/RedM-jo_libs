import { useLangStore } from '@/stores/lang';
const { defineProps, } = {};
const __VLS_props = defineProps();
const langStore = useLangStore();
function getString(key, fallback) {
    return langStore.getString(key, fallback);
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
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-summary" },
    });
    /** @type {__VLS_StyleScopedClasses['price-summary']} */ ;
    if (__VLS_ctx.warning) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-message price-message--warning" },
        });
        /** @type {__VLS_StyleScopedClasses['price-message']} */ ;
        /** @type {__VLS_StyleScopedClasses['price-message--warning']} */ ;
        (__VLS_ctx.warning);
    }
    if (__VLS_ctx.lines.length === 1) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-summary__label" },
        });
        /** @type {__VLS_StyleScopedClasses['price-summary__label']} */ ;
        (__VLS_ctx.singleLabel);
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        (__VLS_ctx.lines[0]);
    }
    else {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-summary__label" },
        });
        const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiPreview'), }, ...__VLS_directiveHookArgsRest(__VLS_0));
        /** @type {__VLS_StyleScopedClasses['price-summary__label']} */ ;
        const __VLS_1 = __VLS_tryAsConstant((__VLS_ctx.lines));
        for (const [line, index] of __VLS_vFor(__VLS_nonNull(__VLS_1))) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
                key: (index),
                ...{ class: "price-summary__line" },
            });
            /** @type {__VLS_StyleScopedClasses['price-summary__line']} */ ;
            __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
            (getString("inputNuiOption", "Option"));
            (index + 1);
            __VLS_asFunctionalElement1(__VLS_intrinsics.strong, __VLS_intrinsics.strong)({});
            (line);
            // @ts-ignore
            [warning, warning, lines, lines, lines, singleLabel, vI18n,];
        }
    }
    // @ts-ignore
    [];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeProps: {},
});
export default {};
