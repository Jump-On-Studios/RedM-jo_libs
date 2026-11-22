import { computed, ref, useTemplateRef, watch } from 'vue';
import { useAutofocus } from '@/composables/useAutofocus';
import { useEntryStyle } from '@/composables/useEntryStyle';
import { useEntryValue } from '@/composables/useEntryValue';
import { usePopoverPosition } from '@/composables/usePopoverPosition';
const { defineProps, } = {};
const props = defineProps();
const root = useTemplateRef('root');
const field = useTemplateRef('field');
const style = useEntryStyle(() => props.entry);
const { value, hasError } = useEntryValue(() => props.entry);
const isOpen = ref(false);
const activeIndex = ref(-1);
const listStyle = usePopoverPosition(field, isOpen);
const options = computed(() => props.entry.options ?? []);
useAutofocus(() => props.entry.id, () => field.value);
function isSelected(option) {
    return value.value?.value === option.value;
}
function open() {
    isOpen.value = true;
    activeIndex.value = options.value.findIndex(isSelected);
}
function close() {
    isOpen.value = false;
}
function toggle() {
    if (isOpen.value)
        close();
    else
        open();
}
function select(option) {
    value.value = option;
    close();
    field.value?.focus();
}
function move(offset) {
    const total = options.value.length;
    if (total === 0)
        return;
    activeIndex.value = (activeIndex.value + offset + total) % total;
}
/**
 * The panel listens for Enter and Escape on the window, so every key the list
 * consumes must be stopped here to avoid submitting or cancelling the panel.
 */
function onKeyDown(event) {
    switch (event.code) {
        case 'Escape':
            if (!isOpen.value)
                return;
            event.preventDefault();
            event.stopPropagation();
            close();
            return;
        case 'Enter':
        case 'Space':
            event.preventDefault();
            event.stopPropagation();
            if (!isOpen.value) {
                open();
                return;
            }
            {
                const option = options.value[activeIndex.value];
                if (option)
                    select(option);
            }
            return;
        case 'ArrowDown':
        case 'ArrowUp':
            event.preventDefault();
            event.stopPropagation();
            if (!isOpen.value) {
                open();
                return;
            }
            move(event.code === 'ArrowDown' ? 1 : -1);
    }
}
function onDocumentPointerDown(event) {
    if (root.value?.contains(event.target))
        return;
    close();
}
watch(isOpen, (opened, _, onCleanup) => {
    if (!opened)
        return;
    document.addEventListener('pointerdown', onDocumentPointerDown);
    onCleanup(() => {
        document.removeEventListener('pointerdown', onDocumentPointerDown);
    });
});
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
    __VLS_withDotValue(value, {});
    __VLS_withDotValue(isOpen, {});
    __VLS_withDotValue(activeIndex, {});
    __VLS_withDotValue(options, {});
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ref: "root",
        ...{ class: "entry-select" },
        ...{ class: ([__VLS_ctx.entry.class, { 'is-open': isOpen.value }]) },
        ...{ style: (__VLS_unwrap(style, {})) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-select']} */ ;
    /** @type {__VLS_StyleScopedClasses['is-open']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
        ...{ onClick: (toggle) },
        ...{ onKeydown: (onKeyDown) },
        ref: "field",
        id: (__VLS_ctx.entry.id),
        type: "button",
        ...{ class: "entry-field entry-select__trigger" },
        ...{ class: ({ error: __VLS_unwrap(hasError, {}) }) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-field']} */ ;
    /** @type {__VLS_StyleScopedClasses['entry-select__trigger']} */ ;
    /** @type {__VLS_StyleScopedClasses['error']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: ({ 'entry-select__placeholder': !value.value }) },
    });
    /** @type {__VLS_StyleScopedClasses['entry-select__placeholder']} */ ;
    (value.value?.label ?? __VLS_ctx.entry.placeholder ?? '');
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({
        ...{ class: "entry-select__caret" },
    });
    /** @type {__VLS_StyleScopedClasses['entry-select__caret']} */ ;
    (isOpen.value ? '▲' : '▼');
    if (isOpen.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.ul, __VLS_intrinsics.ul)({
            ...{ class: "entry-select__list" },
            ...{ style: (__VLS_unwrap(listStyle, {})) },
        });
        /** @type {__VLS_StyleScopedClasses['entry-select__list']} */ ;
        const __VLS_0 = __VLS_tryAsConstant((options.value));
        for (const [option, index] of __VLS_vFor(__VLS_nonNull(__VLS_0))) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.li, __VLS_intrinsics.li)({
                key: (index),
            });
            __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
                ...{ onClick: (...[$event]) => {
                        void $event;
                        if (!(isOpen.value))
                            throw 0;
                        return (select(option));
                        // @ts-ignore
                        [entry, entry, entry, isOpen, isOpen, isOpen, style, hasError, value, value, listStyle, options,];
                    } },
                ...{ onMousemove: (...[$event]) => {
                        void $event;
                        if (!(isOpen.value))
                            throw 0;
                        return (activeIndex.value = index);
                        // @ts-ignore
                        [activeIndex,];
                    } },
                type: "button",
                ...{ class: "entry-select__option" },
                ...{ class: ({
                        'is-active': index === activeIndex.value,
                        'is-selected': isSelected(option),
                    }) },
            });
            /** @type {__VLS_StyleScopedClasses['entry-select__option']} */ ;
            /** @type {__VLS_StyleScopedClasses['is-active']} */ ;
            /** @type {__VLS_StyleScopedClasses['is-selected']} */ ;
            (option.label);
            // @ts-ignore
            [activeIndex,];
        }
        if (options.value.length === 0) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.li, __VLS_intrinsics.li)({
                ...{ class: "entry-select__empty" },
            });
            const __VLS_1 = __VLS_asFunctionalDirective(__VLS_directives.vI18n, {});
            __VLS_1(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('inputNuiNoOptionAvailable'), }, ...__VLS_directiveHookArgsRest(__VLS_1));
            /** @type {__VLS_StyleScopedClasses['entry-select__empty']} */ ;
        }
    }
    // @ts-ignore
    [options, vI18n,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({
    __typeProps: {},
});
export default {};
