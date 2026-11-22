import { onBeforeUnmount, onMounted, ref } from "vue";
import InputRow from "@/components/InputRow.vue";
import { useBackdropSize } from "@/composables/useBackdropSize";
import { useInputStore } from "@/stores/input";
const inputStore = useInputStore();
const container = ref(null);
useBackdropSize(() => container.value);
/** The nine patches of the backdrop, named by the cell they cover. */
const BACKDROP_PATCHES = ["left", "center", "right"].flatMap((column) => ["top", "middle", "bottom"].map((row) => `is-${column} is-${row}`));
/**
 * Set while Enter is held down, so a key repeat cannot submit the next panel
 * opened by the same interaction.
 */
let ignoreEnter = false;
/** Shared gate between the field-level Enter and the global one. */
function acceptsEnter() {
    if (ignoreEnter)
        return false;
    if (inputStore.isEnterGuarded()) {
        ignoreEnter = true;
        return false;
    }
    return true;
}
/** Enter pressed inside a field: submits whatever buttons the panel declares. */
function submitFromField() {
    if (!acceptsEnter())
        return;
    inputStore.submit("Enter");
}
function onKeyDown(event) {
    if (event.code === "Escape") {
        event.preventDefault();
        inputStore.cancel();
        return;
    }
    if (event.code !== "Enter")
        return;
    if (!acceptsEnter())
        return;
    // A focused field handles its own Enter through the submit event.
    if (document.activeElement?.tagName !== "BODY")
        return;
    // With buttons on screen, the player is expected to pick one.
    if (inputStore.hasButton)
        return;
    inputStore.submit("Enter");
}
function onKeyUp(event) {
    if (event.code === "Enter")
        ignoreEnter = false;
}
onMounted(() => {
    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);
});
onBeforeUnmount(() => {
    window.removeEventListener("keydown", onKeyDown);
    window.removeEventListener("keyup", onKeyUp);
});
const __VLS_ctx = {};
let __VLS_components;
let __VLS_intrinsics;
let __VLS_directives;
void __VLS_ctx, __VLS_components, __VLS_intrinsics, __VLS_directives;
const __VLS_template = () => {
    __VLS_withDotValue(inputStore, {});
    void {};
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-smudge']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-to']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-smudge']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-from']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-overlay__shade']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-to']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-overlay__shade']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-from']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-header']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-from']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-content']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-from']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-footer']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-to']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-header']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-to']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-content']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-to']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-footer']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-overlay__shade']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-header']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-content']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-enter-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-footer']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-overlay__shade']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-header']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-content']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-modal-leave-active']} */ ;
    /** @type {__VLS_StyleScopedClasses['input-footer']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "input-overlay" },
    });
    /** @type {__VLS_StyleScopedClasses['input-overlay']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div)({
        ...{ class: "input-overlay__shade" },
        'aria-hidden': "true",
    });
    /** @type {__VLS_StyleScopedClasses['input-overlay__shade']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "input-stage" },
    });
    const __VLS_0 = __VLS_asFunctionalDirective(__VLS_directives.vUiScaler, {});
    __VLS_0(__VLS_nonNull(null), { ...__VLS_directiveBindingRestFields, value: ('center center'), }, ...__VLS_directiveHookArgsRest(__VLS_0));
    /** @type {__VLS_StyleScopedClasses['input-stage']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div)({
        ...{ class: "input-smudge" },
        'aria-hidden': "true",
    });
    /** @type {__VLS_StyleScopedClasses['input-smudge']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "input-animation-surface" },
    });
    /** @type {__VLS_StyleScopedClasses['input-animation-surface']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ref: "container",
        ...{ class: "input-container" },
    });
    /** @type {__VLS_StyleScopedClasses['input-container']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
        ...{ class: "input-backdrop" },
        'aria-hidden': "true",
    });
    /** @type {__VLS_StyleScopedClasses['input-backdrop']} */ ;
    const __VLS_1 = __VLS_tryAsConstant((__VLS_unwrap(BACKDROP_PATCHES, {})));
    for (const [patch] of __VLS_vFor(__VLS_nonNull(__VLS_1))) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.span)({
            key: (patch),
            ...{ class: "input-backdrop__patch" },
            ...{ class: (patch) },
        });
        /** @type {__VLS_StyleScopedClasses['input-backdrop__patch']} */ ;
        // @ts-ignore
        [vUiScaler, BACKDROP_PATCHES,];
    }
    if (inputStore.value.headerRows.length) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "input-header" },
        });
        /** @type {__VLS_StyleScopedClasses['input-header']} */ ;
        const __VLS_2 = __VLS_tryAsConstant((inputStore.value.headerRows));
        for (const [row, rowIndex] of __VLS_vFor(__VLS_nonNull(__VLS_2))) {
            const __VLS_3 = InputRow;
            // @ts-ignore
            const __VLS_4 = __VLS_asFunctionalComponent1(__VLS_3, new __VLS_3({
                // @ts-ignore
                ...{ 'onSubmit': {} }, key: (rowIndex), row: (row),
            }));
            const __VLS_5 = __VLS_4({
                ...{ 'onSubmit': {} },
                key: (rowIndex),
                row: (row),
            }, ...__VLS_functionalComponentArgsRest(__VLS_4));
            let __VLS_8;
            const __VLS_9 = {
                /** @type {typeof __VLS_8.submit} */
                onSubmit: (submitFromField),
            };
            void __VLS_9;
            var __VLS_6;
            var __VLS_7;
            // @ts-ignore
            [inputStore, inputStore,];
        }
    }
    if (inputStore.value.contentRows.length) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "input-content" },
        });
        /** @type {__VLS_StyleScopedClasses['input-content']} */ ;
        const __VLS_10 = __VLS_tryAsConstant((inputStore.value.contentRows));
        for (const [row, rowIndex] of __VLS_vFor(__VLS_nonNull(__VLS_10))) {
            const __VLS_11 = InputRow;
            // @ts-ignore
            const __VLS_12 = __VLS_asFunctionalComponent1(__VLS_11, new __VLS_11({
                // @ts-ignore
                ...{ 'onSubmit': {} }, key: (rowIndex), row: (row),
            }));
            const __VLS_13 = __VLS_12({
                ...{ 'onSubmit': {} },
                key: (rowIndex),
                row: (row),
            }, ...__VLS_functionalComponentArgsRest(__VLS_12));
            let __VLS_16;
            const __VLS_17 = {
                /** @type {typeof __VLS_16.submit} */
                onSubmit: (submitFromField),
            };
            void __VLS_17;
            var __VLS_14;
            var __VLS_15;
            // @ts-ignore
            [inputStore, inputStore,];
        }
    }
    if (inputStore.value.footerRows.length) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "input-footer" },
        });
        /** @type {__VLS_StyleScopedClasses['input-footer']} */ ;
        const __VLS_18 = __VLS_tryAsConstant((inputStore.value.footerRows));
        for (const [row, rowIndex] of __VLS_vFor(__VLS_nonNull(__VLS_18))) {
            const __VLS_19 = InputRow;
            // @ts-ignore
            const __VLS_20 = __VLS_asFunctionalComponent1(__VLS_19, new __VLS_19({
                // @ts-ignore
                ...{ 'onSubmit': {} }, key: (rowIndex), row: (row),
            }));
            const __VLS_21 = __VLS_20({
                ...{ 'onSubmit': {} },
                key: (rowIndex),
                row: (row),
            }, ...__VLS_functionalComponentArgsRest(__VLS_20));
            let __VLS_24;
            const __VLS_25 = {
                /** @type {typeof __VLS_24.submit} */
                onSubmit: (submitFromField),
            };
            void __VLS_25;
            var __VLS_22;
            var __VLS_23;
            // @ts-ignore
            [inputStore, inputStore,];
        }
    }
    // @ts-ignore
    [];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({});
export default {};
