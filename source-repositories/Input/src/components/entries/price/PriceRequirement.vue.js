import { computed } from 'vue';
import { requirementError, typeLabel } from '@/helpers/price';
import { useLangStore } from '@/stores/lang';
const { defineProps, defineEmits, } = {};
const props = defineProps();
const emit = defineEmits();
const langStore = useLangStore();
const error = computed(() => requirementError(props.requirement));
const requirementIcons = {
    money: './assets/ui/dollar.png',
    gold: './assets/ui/gold.png',
    item: './assets/ui/item.png',
};
function requirementIcon(type) {
    return requirementIcons[type];
}
function getString(key, fallback) {
    return langStore.getString(key, fallback);
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
    __VLS_withDotValue(error, {});
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.article, __VLS_intrinsics.article)({
        ...{ class: "price-requirement" },
        ...{ class: ({ 'is-invalid': error.value }) },
    });
    /** @type {__VLS_StyleScopedClasses['price-requirement']} */ ;
    /** @type {__VLS_StyleScopedClasses['is-invalid']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "price-requirement__kind" },
    });
    /** @type {__VLS_StyleScopedClasses['price-requirement__kind']} */ ;
    if (requirementIcon(__VLS_ctx.requirement.type)) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-requirement__icon" },
            ...{ class: (`is-${__VLS_ctx.requirement.type}`) },
            'aria-hidden': "true",
        });
        /** @type {__VLS_StyleScopedClasses['price-requirement__icon']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.img)({
            src: (requirementIcon(__VLS_ctx.requirement.type)),
            alt: "",
        });
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
    (__VLS_unwrap(typeLabel, {})(__VLS_ctx.requirement.type));
    if (__VLS_ctx.requirement.type === 'item') {
        __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
            ...{ class: "price-field" },
        });
        /** @type {__VLS_StyleScopedClasses['price-field']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-field__label" },
        });
        const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiItem'), }, ...__VLS_directiveHookArgsRest(__VLS_0));
        /** @type {__VLS_StyleScopedClasses['price-field__label']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.input)({
            value: (__VLS_ctx.requirement.itemName),
            type: "text",
            ...{ class: "entry-input" },
            placeholder: "item_name",
        });
        /** @type {__VLS_StyleScopedClasses['entry-input']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
            ...{ class: "price-field price-field--narrow" },
        });
        /** @type {__VLS_StyleScopedClasses['price-field']} */ ;
        /** @type {__VLS_StyleScopedClasses['price-field--narrow']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-field__label" },
        });
        const __VLS_1 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_1(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiQuantity'), }, ...__VLS_directiveHookArgsRest(__VLS_1));
        /** @type {__VLS_StyleScopedClasses['price-field__label']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.input)({
            type: "number",
            min: "1",
            step: "1",
            ...{ class: "entry-input" },
            placeholder: "1",
        });
        (__VLS_ctx.requirement.quantity);
        /** @type {__VLS_StyleScopedClasses['entry-input']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
            ...{ class: "price-checkbox" },
        });
        /** @type {__VLS_StyleScopedClasses['price-checkbox']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.input)({
            type: "checkbox",
        });
        (__VLS_ctx.requirement.keep);
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        const __VLS_2 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_2(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiKeep'), }, ...__VLS_directiveHookArgsRest(__VLS_2));
    }
    else {
        __VLS_asFunctionalElement1(__VLS_intrinsics.label, __VLS_intrinsics.label)({
            ...{ class: "price-field" },
        });
        /** @type {__VLS_StyleScopedClasses['price-field']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-field__label" },
        });
        const __VLS_3 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_3(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiAmount'), }, ...__VLS_directiveHookArgsRest(__VLS_3));
        /** @type {__VLS_StyleScopedClasses['price-field__label']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.input)({
            type: "number",
            min: "0",
            step: "0.01",
            ...{ class: "entry-input" },
            placeholder: "0",
        });
        (__VLS_ctx.requirement.value);
        /** @type {__VLS_StyleScopedClasses['entry-input']} */ ;
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
        ...{ onClick: (...[$event]) => {
                void $event;
                return (__VLS_unwrap(emit, {})('remove'));
                // @ts-ignore
                [error, requirement, requirement, requirement, requirement, requirement, requirement, requirement, requirement, requirement, typeLabel, vI18n, vI18n, vI18n, vI18n, emit,];
            } },
        type: "button",
        ...{ class: "price-icon-button" },
        title: (getString('inputNuiRemoveRequirement', 'Remove requirement')),
    });
    /** @type {__VLS_StyleScopedClasses['price-icon-button']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.img)({
        src: "/assets/ui/trash.png",
        alt: "",
        'aria-hidden': "true",
    });
    if (error.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-message price-message--error" },
        });
        /** @type {__VLS_StyleScopedClasses['price-message']} */ ;
        /** @type {__VLS_StyleScopedClasses['price-message--error']} */ ;
        (error.value);
    }
    // @ts-ignore
    [error, error,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeEmits: {},
    __typeProps: {},
});
export default {};
