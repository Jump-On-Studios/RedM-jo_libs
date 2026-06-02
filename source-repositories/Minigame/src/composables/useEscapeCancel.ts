import { onBeforeUnmount, onMounted } from "vue";

export function useEscapeCancel(cancel: () => void | Promise<void>) {
  function onKeyDown(event: KeyboardEvent) {
    if (event.key !== "Escape") return;

    event.preventDefault();
    cancel();
  }

  onMounted(() => {
    window.addEventListener("keydown", onKeyDown);
  });

  onBeforeUnmount(() => {
    window.removeEventListener("keydown", onKeyDown);
  });
}
