import { computed, onBeforeUnmount, onMounted, ref, useTemplateRef } from 'vue';
import VueDatePicker from '@vuepic/vue-datepicker';
import { useEntryStyle } from '@/composables/useEntryStyle';
import { useEntryValue } from '@/composables/useEntryValue';
import { usePopoverPosition } from '@/composables/usePopoverPosition';
const { defineProps, defineEmits, } = {};
const props = defineProps();
const emit = defineEmits();
const root = useTemplateRef('root');
const field = useTemplateRef('field');
const style = useEntryStyle(() => props.entry);
const { value, hasError } = useEntryValue(() => props.entry);
const isOpen = ref(false);
const popoverStyle = usePopoverPosition(field, isOpen);
const yearRange = computed(() => props.entry.yearRange ?? [1900, 2100]);
/** Opens the calendar on the first allowed year rather than on today. */
const startDate = computed(() => new Date(yearRange.value[0], 0, 1));
const displayValue = computed(() => {
    const current = value.value;
    if (!current)
        return '';
    if (typeof current === 'string')
        return current;
    if (current instanceof Date)
        return current.toLocaleDateString();
    return String(current);
});
function close(restoreFocus = true) {
    isOpen.value = false;
    if (restoreFocus)
        field.value?.focus();
}
function onDocumentPointerDown(event) {
    const target = event.target;
    if (!isOpen.value || !(target instanceof Node) || root.value?.contains(target))
        return;
    close(false);
}
function toggle() {
    if (isOpen.value)
        close();
    else
        isOpen.value = true;
}
onMounted(() => {
    document.addEventListener('pointerdown', onDocumentPointerDown);
});
onBeforeUnmount(() => {
    document.removeEventListener('pointerdown', onDocumentPointerDown);
});
/** Keeps the panel from submitting or closing while the calendar is open. */
function onKeyDown(event) {
    if (event.code === 'Escape') {
        if (!isOpen.value)
            return;
        event.preventDefault();
        event.stopPropagation();
        close();
        return;
    }
    if (event.code !== 'Enter')
        return;
    event.preventDefault();
    event.stopPropagation();
    if (isOpen.value)
        return;
    emit('submit');
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
    __VLS_withDotValue(displayValue, {});
    __VLS_withDotValue(isOpen, {});
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ onKeydown: (onKeyDown) },
        ref: "root",
        ...{ class: "entry-date" },
        ...{ class: ([__VLS_ctx.entry.class, { 'is-open': isOpen.value }]) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-date']} */ ;
    /** @type {__VLS_StyleScopedClasses['is-open']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
        ...{ onClick: (toggle) },
        ref: "field",
        id: (__VLS_ctx.entry.id),
        type: "button",
        ...{ class: "entry-field entry-date__trigger" },
        ...{ class: ({ error: __VLS_unwrap(hasError, {}) }) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-field']} */ ;
    /** @type {__VLS_StyleScopedClasses['entry-date__trigger']} */ ;
    /** @type {__VLS_StyleScopedClasses['error']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: ({ 'entry-date__placeholder': !displayValue.value }) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-date__placeholder']} */ ;
    (displayValue.value || __VLS_ctx.entry.placeholder || '');
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "entry-date__caret" },
    });
    /** @type {__VLS_StyleScopedClasses['entry-date__caret']} */ ;
    (isOpen.value ? '▲' : '▼');
    if (isOpen.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "entry-date__popover" },
            ...{ style: (__VLS_unwrap(popoverStyle, {})) },
        });
        /** @type {__VLS_StyleScopedClasses['entry-date__popover']} */ ;
        let __VLS_0;
        /** @ts-ignore @type { | typeof VueDatePicker} */
        VueDatePicker;
        // @ts-ignore
        const __VLS_1 = __VLS_asFunctionalComponent1(__VLS_0, new __VLS_0({
            // @ts-ignore
            ...{ 'onUpdate:modelValue': {} }, modelValue: (__VLS_unwrap(value, {})), inline: true, autoApply: true, dark: true, preventMinMaxNavigation: true, teleport: (false), enableTimePicker: (false), yearRange: (__VLS_unwrap(yearRange, {})), startDate: (__VLS_unwrap(startDate, {})), format: (__VLS_ctx.entry.format), modelType: (__VLS_ctx.entry.format),
        }));
        const __VLS_2 = __VLS_1({
            ...{ 'onUpdate:modelValue': {} },
            modelValue: (__VLS_unwrap(value, {})),
            inline: true,
            autoApply: true,
            dark: true,
            preventMinMaxNavigation: true,
            teleport: (false),
            enableTimePicker: (false),
            yearRange: (__VLS_unwrap(yearRange, {})),
            startDate: (__VLS_unwrap(startDate, {})),
            format: (__VLS_ctx.entry.format),
            modelType: (__VLS_ctx.entry.format),
        }, ...__VLS_functionalComponentArgsRest(__VLS_1));
        let __VLS_5;
        const __VLS_6 = {
            /** @type {typeof __VLS_5.'update:modelValue'} */
            'onUpdate:modelValue': (close),
        };
        void __VLS_6;
        var __VLS_3;
        var __VLS_4;
    }
    // @ts-ignore
    [entry, entry, entry, entry, entry, isOpen, isOpen, isOpen, style, hasError, displayValue, displayValue, popoverStyle, value, yearRange, startDate,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeEmits: {},
    __typeProps: {},
});
export default {};
