import { computed } from "vue";
import PriceRequirement from "./PriceRequirement.vue";
import { createRequirement, isTypeDisabled, optionError, typeLabel, } from "@/helpers/price";
import { useLangStore } from "@/stores/lang";
const { defineProps, defineEmits, } = {};
const props = defineProps();
const emit = defineEmits();
const langStore = useLangStore();
const error = computed(() => optionError(props.option));
const requirementIcons = {
    money: "./assets/ui/dollar.png",
    gold: "./assets/ui/gold.png",
    item: "./assets/ui/item.png",
};
function typeIcon(type) {
    return requirementIcons[type];
}
function buttonTitle(type) {
    if (!isTypeDisabled(props.option, type)) {
        return `${getString("inputNuiAddCost", "Add")} ${typeLabel(type)}`;
    }
    return `${typeLabel(type)} ${getString("inputNuiAlreadyInOption", "is already in this option.")}`;
}
function getString(key, fallback) {
    return langStore.getString(key, fallback);
}
function addRequirement(type) {
    if (isTypeDisabled(props.option, type))
        return;
    props.option.requirements.push(createRequirement(type));
}
function removeRequirement(index) {
    props.option.requirements.splice(index, 1);
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
    __VLS_asFunctionalElement1(__VLS_intrinsics.section, __VLS_intrinsics.section)({
        ...{ class: "price-option" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.header, __VLS_intrinsics.header)({
        ...{ class: "price-option__header" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option__header']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "price-option__heading" },
    });
    const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
    __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiRequirements'), }, ...__VLS_directiveHookArgsRest(__VLS_0));
    /** @type {__VLS_StyleScopedClasses['price-option__heading']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-option__actions" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option__actions']} */ ;
    if (__VLS_ctx.canDuplicate) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
            ...{ onClick: (...[$event]) => {
                    void $event;
                    if (!(__VLS_ctx.canDuplicate))
                        throw 0;
                    return (__VLS_unwrap(emit, {})('duplicate'));
                    // @ts-ignore
                    [vI18n, canDuplicate, emit,];
                } },
            type: "button",
            ...{ class: "price-option__action" },
            title: (getString('inputNuiDuplicateOption', 'Duplicate option')),
        });
        /** @type {__VLS_StyleScopedClasses['price-option__action']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        const __VLS_1 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_1(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiDuplicateOption'), }, ...__VLS_directiveHookArgsRest(__VLS_1));
    }
    if (__VLS_ctx.canRemove) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
            ...{ onClick: (...[$event]) => {
                    void $event;
                    if (!(__VLS_ctx.canRemove))
                        throw 0;
                    return (__VLS_unwrap(emit, {})('remove'));
                    // @ts-ignore
                    [vI18n, emit, canRemove,];
                } },
            type: "button",
            ...{ class: "price-option__action" },
            title: (getString('inputNuiRemoveOption', 'Remove option')),
            'aria-label': (getString('inputNuiRemoveOption', 'Remove option')),
        });
        /** @type {__VLS_StyleScopedClasses['price-option__action']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        const __VLS_2 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_2(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiRemoveOption'), }, ...__VLS_directiveHookArgsRest(__VLS_2));
    }
    if (__VLS_ctx.option.requirements.length === 0) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "price-option__empty" },
        });
        /** @type {__VLS_StyleScopedClasses['price-option__empty']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        const __VLS_3 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_3(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiAddRequirementToOption'), }, ...__VLS_directiveHookArgsRest(__VLS_3));
    }
    if (error.value && __VLS_ctx.option.requirements.length > 0) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
            ...{ class: "price-message price-message--error" },
        });
        /** @type {__VLS_StyleScopedClasses['price-message']} */ ;
        /** @type {__VLS_StyleScopedClasses['price-message--error']} */ ;
        (error.value);
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-option__requirements" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option__requirements']} */ ;
    const __VLS_4 = __VLS_tryAsConstant((__VLS_ctx.option.requirements));
    for (const [requirement, requirementIndex] of __VLS_vFor(__VLS_nonNull(__VLS_4))) {
        const __VLS_5 = PriceRequirement;
        // @ts-ignore
        const __VLS_6 = __VLS_asFunctionalComponent1(__VLS_5, new __VLS_5({
            // @ts-ignore
            ...{ 'onRemove': {} }, key: (requirement.key), requirement: (requirement),
        }));
        const __VLS_7 = __VLS_6({
            ...{ 'onRemove': {} },
            key: (requirement.key),
            requirement: (requirement),
        }, ...__VLS_functionalComponentArgsRest(__VLS_6));
        let __VLS_10;
        const __VLS_11 = {
            /** @type {typeof __VLS_10.remove} */
            onRemove: (...[$event]) => {
                void $event;
                return (removeRequirement(requirementIndex));
                // @ts-ignore
                [vI18n, vI18n, option, option, option, error, error,];
            },
        };
        void __VLS_11;
        var __VLS_8;
        var __VLS_9;
        // @ts-ignore
        [];
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-option__add" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option__add']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "price-option__help" },
    });
    const __VLS_12 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
    __VLS_12(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiAddRequirement'), }, ...__VLS_directiveHookArgsRest(__VLS_12));
    /** @type {__VLS_StyleScopedClasses['price-option__help']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-option__types" },
    });
    /** @type {__VLS_StyleScopedClasses['price-option__types']} */ ;
    const __VLS_13 = __VLS_tryAsConstant((__VLS_ctx.availableTypes));
    for (const [choice] of __VLS_vFor(__VLS_nonNull(__VLS_13))) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
            ...{ onClick: (...[$event]) => {
                    void $event;
                    return (addRequirement(choice.value));
                    // @ts-ignore
                    [vI18n, availableTypes,];
                } },
            key: (choice.value),
            type: "button",
            ...{ class: "price-type-button" },
            disabled: (__VLS_unwrap(isTypeDisabled, {})(__VLS_ctx.option, choice.value)),
            title: (buttonTitle(choice.value)),
        });
        /** @type {__VLS_StyleScopedClasses['price-type-button']} */ ;
        if (typeIcon(choice.value)) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
                ...{ class: "price-type-button__icon" },
                ...{ class: (`is-${choice.value}`) },
                'aria-hidden': "true",
            });
            /** @type {__VLS_StyleScopedClasses['price-type-button__icon']} */ ;
            __VLS_asFunctionalElement1(__VLS_intrinsics.img)({
                src: (typeIcon(choice.value)),
                alt: "",
            });
        }
        __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
        (__VLS_unwrap(typeLabel, {})(choice.value));
        // @ts-ignore
        [option, isTypeDisabled, typeLabel,];
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
