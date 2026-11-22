import { ref, watch } from 'vue';
export function usePopoverPosition(field, isOpen) {
    const style = ref({});
    watch(isOpen, (opened, _, onCleanup) => {
        if (!opened)
            return;
        const trigger = field.value;
        const stage = trigger?.closest('.input-stage');
        if (!trigger || !stage) {
            isOpen.value = false;
            return;
        }
        // Fixed positioning escapes the scroll area; coordinates stay in the scaled stage.
        const bounds = trigger.getBoundingClientRect();
        const stageBounds = stage.getBoundingClientRect();
        const scale = stageBounds.width / stage.offsetWidth;
        style.value = {
            left: `${(bounds.left - stageBounds.left) / scale}px`,
            top: `${(bounds.bottom - stageBounds.top) / scale + 2}px`,
            '--popover-trigger-width': `${bounds.width / scale}px`,
        };
        const close = () => { isOpen.value = false; };
        const content = trigger.closest('.input-content');
        content?.addEventListener('scroll', close);
        window.addEventListener('resize', close);
        onCleanup(() => {
            content?.removeEventListener('scroll', close);
            window.removeEventListener('resize', close);
        });
    });
    return style;
}
