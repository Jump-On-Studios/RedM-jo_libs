import { onBeforeUnmount, ref } from 'vue';
import { scenarios } from '@/dev';
import { onDevLuaCall } from '@/helpers/luaHelper';
const STORAGE_KEY = 'jo_input:debug-collapsed';
const collapsed = ref(localStorage.getItem(STORAGE_KEY) === 'true');
const lastCall = ref('');
function toggle() {
    collapsed.value = !collapsed.value;
    localStorage.setItem(STORAGE_KEY, String(collapsed.value));
}
const stop = onDevLuaCall((method, data) => {
    lastCall.value = `${method}\n${JSON.stringify(data, null, 2)}`;
});
onBeforeUnmount(stop);
const __VLS_ctx = {};
let __VLS_components;
let __VLS_intrinsics;
let __VLS_directives;
void __VLS_ctx, __VLS_components, __VLS_intrinsics, __VLS_directives;
const __VLS_template = () => {
    __VLS_withDotValue(collapsed, {});
    __VLS_withDotValue(lastCall, {});
    void {};
    __VLS_asFunctionalElement1(__VLS_intrinsics.aside, __VLS_intrinsics.aside)({
        ...{ class: "debug-panel" },
        ...{ class: ({ 'is-collapsed': collapsed.value }) },
    });
    /** @type {__VLS_StyleScopedClasses['debug-panel']} */ ;
    /** @type {__VLS_StyleScopedClasses['is-collapsed']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.header, __VLS_intrinsics.header)({
        ...{ onClick: (toggle) },
        ...{ class: "debug-panel__header" },
    });
    /** @type {__VLS_StyleScopedClasses['debug-panel__header']} */ ;
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
    __VLS_asFunctionalElement1(__VLS_intrinsics.span, __VLS_intrinsics.span)({});
    (collapsed.value ? '+' : '−');
    if (!collapsed.value) {
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "debug-panel__body" },
        });
        /** @type {__VLS_StyleScopedClasses['debug-panel__body']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "debug-panel__scenarios" },
        });
        /** @type {__VLS_StyleScopedClasses['debug-panel__scenarios']} */ ;
        const __VLS_0 = __VLS_tryAsConstant((__VLS_unwrap(scenarios, {})));
        for (const [scenario] of __VLS_vFor(__VLS_nonNull(__VLS_0))) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.button, __VLS_intrinsics.button)({
                ...{ onClick: (...[$event]) => {
                        void $event;
                        if (!(!collapsed.value))
                            throw 0;
                        return (scenario.run());
                        // @ts-ignore
                        [collapsed, collapsed, collapsed, scenarios,];
                    } },
                key: (scenario.id),
                type: "button",
                ...{ class: "debug-panel__button" },
            });
            /** @type {__VLS_StyleScopedClasses['debug-panel__button']} */ ;
            (scenario.label);
            // @ts-ignore
            [];
        }
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "debug-panel__output" },
        });
        /** @type {__VLS_StyleScopedClasses['debug-panel__output']} */ ;
        __VLS_asFunctionalElement1(__VLS_intrinsics.div, __VLS_intrinsics.div)({
            ...{ class: "debug-panel__label" },
        });
        /** @type {__VLS_StyleScopedClasses['debug-panel__label']} */ ;
        if (lastCall.value) {
            __VLS_asFunctionalElement1(__VLS_intrinsics.pre, __VLS_intrinsics.pre)({});
            (lastCall.value);
        }
        else {
            __VLS_asFunctionalElement1(__VLS_intrinsics.p, __VLS_intrinsics.p)({
                ...{ class: "debug-panel__empty" },
            });
            /** @type {__VLS_StyleScopedClasses['debug-panel__empty']} */ ;
        }
    }
    // @ts-ignore
    [lastCall, lastCall,];
    return {};
};
void [__VLS_template];
const __VLS_export = (await import('vue')).defineComponent({});
export default {};
