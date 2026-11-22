import { defineAsyncComponent } from 'vue';
import Bridge from '@/components/Bridge.vue';
import InputModal from '@/components/InputModal.vue';
import { useInputStore } from '@/stores/input';
// Statically false in production, so the debug panel and its fixtures are
// dropped from the bundle instead of shipping with the resource.
const DevComponent = import.meta.env.DEV
    ? defineAsyncComponent(() => import('@/components/debug/DevComponent.vue'))
    : null;
const inputStore = useInputStore();
const __VLS_ctx = {};
let __VLS_components;
let __VLS_intrinsics;
let __VLS_directives;
void __VLS_ctx, __VLS_components, __VLS_intrinsics, __VLS_directives;
const __VLS_template = () => {
    __VLS_withDotValue(DevComponent, {});
    __VLS_withDotValue(inputStore, {});
    const __VLS_0 = Bridge;
    // @ts-ignore
    const __VLS_1 = __VLS_asFunctionalComponent1(__VLS_0, new __VLS_0({
    // @ts-ignore
    }));
    const __VLS_2 = __VLS_1({}, ...__VLS_functionalComponentArgsRest(__VLS_1));
    if (DevComponent.value) {
        const __VLS_5 = (DevComponent.value);
        // @ts-ignore
        const __VLS_6 = __VLS_asFunctionalComponent1(__VLS_5, new __VLS_5({
        // @ts-ignore
        }));
        const __VLS_7 = __VLS_6({}, ...__VLS_functionalComponentArgsRest(__VLS_6));
    }
    let __VLS_10;
    /** @ts-ignore @type { | typeof __VLS_components.Transition | typeof __VLS_components.Transition} */
    Transition;
    // @ts-ignore
    const __VLS_11 = __VLS_asFunctionalComponent1(__VLS_10, new __VLS_10({
        // @ts-ignore
        name: "input-modal",
    }));
    const __VLS_12 = __VLS_11({
        name: "input-modal",
    }, ...__VLS_functionalComponentArgsRest(__VLS_11));
    var __VLS_13;
    const { default: __VLS_15 } = __VLS_nonNull(__VLS_13.slots);
    if (inputStore.value.visible) {
        const __VLS_16 = InputModal;
        // @ts-ignore
        const __VLS_17 = __VLS_asFunctionalComponent1(__VLS_16, new __VLS_16({
        // @ts-ignore
        }));
        const __VLS_18 = __VLS_17({}, ...__VLS_functionalComponentArgsRest(__VLS_17));
    }
    // @ts-ignore
    [DevComponent, DevComponent, inputStore,];
    // @ts-ignore
    [];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({});
export default {};
