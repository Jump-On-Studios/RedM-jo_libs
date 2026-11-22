import { computed, ref, watch } from "vue";
import PriceOption from "./price/PriceOption.vue";
import PriceSummary from "./price/PriceSummary.vue";
import { useEntryStyle } from "@/composables/useEntryStyle";
import { useEntryValue } from "@/composables/useEntryValue";
import { useLangStore } from "@/stores/lang";
import { ALL_COST_TYPES, areOptionsValid, buildPriceValue, createOption, createRequirement, isFreeOption, optionError, parsePriceValue, summarizeOption, } from "@/helpers/price";
const { defineProps, } = {};
const props = defineProps();
const style = useEntryStyle(() => props.entry);
const langStore = useLangStore();
const { value, hasError } = useEntryValue(() => props.entry);
const allowOr = computed(() => props.entry.allowOR ?? true);
const availableTypes = computed(() => {
    const allowed = props.entry.options;
    if (!allowed || allowed.length === 0)
        return ALL_COST_TYPES;
    return ALL_COST_TYPES.filter((choice) => allowed.includes(choice.value));
});
// The initial value comes from Lua in any shape jo.pricing accepts.
const options = ref(parsePriceValue(props.entry.value, allowOr.value));
const activeOptionKey = ref(options.value[0]?.key ?? null);
const activeOptionIndex = computed(() => {
    const index = options.value.findIndex((option) => option.key === activeOptionKey.value);
    return index >= 0 ? index : 0;
});
const activeOption = computed(() => options.value[activeOptionIndex.value] ?? null);
const usableOptions = computed(() => allowOr.value ? options.value : options.value.slice(0, 1));
/** Null while an option is incomplete, which makes the `required` check fail. */
const priceValue = computed(() => buildPriceValue(options.value, allowOr.value));
const warning = computed(() => {
    if (areOptionsValid(usableOptions.value))
        return null;
    return langStore.getString("inputNuiPriceInvalid", "This price cannot be confirmed until every option is valid.");
});
const summaryLines = computed(() => {
    if (options.value.length > 1 && allowOr.value)
        return options.value.map(summarizeOption);
    return options.value
        .filter((option) => option.requirements.length > 0)
        .map(summarizeOption);
});
const singleLabel = computed(() => {
    if (warning.value)
        return langStore.getString("inputNuiCurrentDraft", "Current draft:");
    if (usableOptions.value.length === 1 && isFreeOption(usableOptions.value[0]))
        return langStore.getString("inputNuiPrice", "Price:");
    return langStore.getString("inputNuiPlayerPays", "Player pays:");
});
function getString(key, fallback) {
    return langStore.getString(key, fallback);
}
function addOption() {
    if (!allowOr.value)
        return;
    const option = createOption();
    options.value.push(option);
    activeOptionKey.value = option.key;
}
function duplicateOption(index) {
    if (!allowOr.value)
        return;
    const source = options.value[index];
    if (!source)
        return;
    const duplicate = createOption(source.requirements.map((requirement) => createRequirement(requirement.type, {
        value: requirement.value,
        itemName: requirement.itemName,
        quantity: requirement.quantity,
        keep: requirement.keep,
    })));
    options.value.splice(index + 1, 0, duplicate);
    activeOptionKey.value = duplicate.key;
}
function removeOption(index) {
    if (options.value.length <= 1)
        return;
    const removedOption = options.value[index];
    options.value.splice(index, 1);
    if (removedOption?.key === activeOptionKey.value) {
        activeOptionKey.value =
            options.value[index]?.key ?? options.value[index - 1]?.key ?? null;
    }
}
function selectOption(key) {
    if (options.value.some((option) => option.key === key))
        activeOptionKey.value = key;
}
watch(allowOr, (allowed) => {
    if (!allowed && options.value.length > 1) {
        options.value = [options.value[0]];
        activeOptionKey.value = options.value[0]?.key ?? null;
    }
});
// Publishes the canonical payload as soon as the form is mounted, so the entry
// already holds a value before any button is pressed.
watch(priceValue, (next) => (value.value = next), { immediate: true });
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
    __VLS_withDotValue(allowOr, {});
    __VLS_withDotValue(activeOptionKey, {});
    __VLS_withDotValue(activeOption, {});
    __VLS_withDotValue(options, {});
    __VLS_withDotValue(summaryLines, {});
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-form" },
        ...{ class: ([__VLS_ctx.entry.class, { error: __VLS_unwrap(hasError, {}) }]) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['price-form']} */ ;
    /** @type {__VLS_StyleScopedClasses['error']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "price-form__heading" },
    });
    /** @type {__VLS_StyleScopedClasses['price-form__heading']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
    const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
    __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiPaymentOptions'), }, ...__VLS_directiveHookArgsRest(__VLS_0));
    if (allowOr.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.small, __VLS_intrinsics.small)({});
        const __VLS_1 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
        __VLS_1(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiOrExplanation'), }, ...__VLS_directiveHookArgsRest(__VLS_1));
    }
    if (allowOr.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "price-form__tabs" },
            role: "tablist",
            'aria-label': (getString('inputNuiPaymentOptions', 'Payment options')),
        });
        /** @type {__VLS_StyleScopedClasses['price-form__tabs']} */ ;
        const __VLS_2 = __VLS_tryAsConstant((options.value));
        for (const [option, index] of __VLS_vFor(__VLS_nonNull(__VLS_2))) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
                ...{ onClick: (...[$event]) => {
                        void $event;
                        if (!(allowOr.value))
                            throw 0;
                        return (selectOption(option.key));
                        // @ts-ignore
                        [entry, hasError, style, vI18n, vI18n, allowOr, allowOr, options,];
                    } },
                id: (`price-option-tab-${option.key}`),
                key: (option.key),
                type: "button",
                ...{ class: "price-form__tab" },
                ...{ class: ({
                        active: option.key === activeOptionKey.value,
                        invalid: __VLS_unwrap(optionError, {})(option),
                    }) },
                role: "tab",
                'aria-selected': (option.key === activeOptionKey.value),
                'aria-controls': "price-option-panel",
            });
            /** @type {__VLS_StyleScopedClasses['price-form__tab']} */ ;
            /** @type {__VLS_StyleScopedClasses['active']} */ ;
            /** @type {__VLS_StyleScopedClasses['invalid']} */ ;
            __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
                ...{ class: "price-form__tab-label" },
            });
            /** @type {__VLS_StyleScopedClasses['price-form__tab-label']} */ ;
            (getString("inputNuiOption", "Option"));
            (index + 1);
            if (__VLS_unwrap(optionError, {})(option)) {
                __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
                    ...{ class: "price-form__tab-invalid" },
                    'aria-label': (getString('inputNuiInvalid', 'invalid')),
                });
                /** @type {__VLS_StyleScopedClasses['price-form__tab-invalid']} */ ;
            }
            // @ts-ignore
            [activeOptionKey, activeOptionKey, optionError, optionError,];
        }
        __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
            ...{ onClick: (addOption) },
            type: "button",
            ...{ class: "price-form__tab price-form__tab--add" },
            'aria-label': (getString('inputNuiAddPaymentOption', 'Add another payment option')),
        });
        /** @type {__VLS_StyleScopedClasses['price-form__tab']} */ ;
        /** @type {__VLS_StyleScopedClasses['price-form__tab--add']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.img)({
            src: "/assets/ui/plus.png",
            alt: "",
            'aria-hidden': "true",
        });
    }
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        id: "price-option-panel",
        ...{ class: "price-form__options" },
        role: "tabpanel",
        'aria-labelledby': (allowOr.value && activeOption.value
            ? `price-option-tab-${activeOption.value.key}`
            : undefined),
    });
    /** @type {__VLS_StyleScopedClasses['price-form__options']} */ ;
    if (activeOption.value) {
        const __VLS_3 = PriceOption;
        // @ts-ignore
        const __VLS_4 = __VLS_asFunctionalComponent1(__VLS_3, new __VLS_3({
            // @ts-ignore
            ...{ 'onDuplicate': {} }, ...{ 'onRemove': {} }, option: (activeOption.value), index: (__VLS_unwrap(activeOptionIndex, {})), availableTypes: (__VLS_unwrap(availableTypes, {})), canRemove: (options.value.length > 1), canDuplicate: (allowOr.value),
        }));
        const __VLS_5 = __VLS_4({
            ...{ 'onDuplicate': {} },
            ...{ 'onRemove': {} },
            option: (activeOption.value),
            index: (__VLS_unwrap(activeOptionIndex, {})),
            availableTypes: (__VLS_unwrap(availableTypes, {})),
            canRemove: (options.value.length > 1),
            canDuplicate: (allowOr.value),
        }, ...__VLS_functionalComponentArgsRest(__VLS_4));
        let __VLS_8;
        const __VLS_9 = {
            /** @type {typeof __VLS_8.duplicate} */
            onDuplicate: (...[$event]) => {
                void $event;
                if (!(activeOption.value))
                    throw 0;
                return (duplicateOption(__VLS_unwrap(activeOptionIndex, {})));
                // @ts-ignore
                [allowOr, allowOr, options, activeOption, activeOption, activeOption, activeOption, activeOptionIndex, activeOptionIndex, availableTypes,];
            },
        };
        void __VLS_9;
        const __VLS_10 = {
            /** @type {typeof __VLS_8.remove} */
            onRemove: (...[$event]) => {
                void $event;
                if (!(activeOption.value))
                    throw 0;
                return (removeOption(__VLS_unwrap(activeOptionIndex, {})));
                // @ts-ignore
                [activeOptionIndex,];
            },
        };
        void __VLS_10;
        var __VLS_6;
        var __VLS_7;
    }
    if (summaryLines.value.length > 0) {
        const __VLS_11 = PriceSummary;
        // @ts-ignore
        const __VLS_12 = __VLS_asFunctionalComponent1(__VLS_11, new __VLS_11({
            // @ts-ignore
            lines: (summaryLines.value), warning: (__VLS_unwrap(warning, {})), singleLabel: (__VLS_unwrap(singleLabel, {})),
        }));
        const __VLS_13 = __VLS_12({
            lines: (summaryLines.value),
            warning: (__VLS_unwrap(warning, {})),
            singleLabel: (__VLS_unwrap(singleLabel, {})),
        }, ...__VLS_functionalComponentArgsRest(__VLS_12));
    }
    // @ts-ignore
    [summaryLines, summaryLines, warning, singleLabel,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeProps: {},
});
export default {};
