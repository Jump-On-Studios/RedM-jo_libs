<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { hideMinigameMock, showLockpickMock } from "@/dev";

interface MockLuaMessage {
  type?: string;
  data?: unknown;
}

interface PanelPosition {
  x: number;
  y: number;
}

const positionStorageKey = "jo_minigame_debug_panel_position";
const collapsedStorageKey = "jo_minigame_debug_panel_collapsed";
const defaultPosition: PanelPosition = { x: 16, y: 16 };

const panelRef = ref<HTMLElement | null>(null);
const lastLuaCallback = ref("No Lua callback yet");
const isCollapsed = ref(false);
const position = ref<PanelPosition>({ ...defaultPosition });
const dragStart = ref<{
  pointerId: number;
  pointerX: number;
  pointerY: number;
  panelX: number;
  panelY: number;
} | null>(null);

const panelStyle = computed(() => ({
  transform: `translate(${position.value.x}px, ${position.value.y}px)`,
}));

function readStoredPosition() {
  const storedPosition = window.localStorage.getItem(positionStorageKey);
  if (!storedPosition) return;

  try {
    const parsed = JSON.parse(storedPosition) as Partial<PanelPosition>;
    if (typeof parsed.x !== "number" || typeof parsed.y !== "number") return;

    position.value = clampPosition({
      x: parsed.x,
      y: parsed.y,
    });
  } catch {
    position.value = { ...defaultPosition };
  }
}

function clampPosition(nextPosition: PanelPosition): PanelPosition {
  const panel = panelRef.value;
  const panelWidth = panel?.offsetWidth || 220;
  const panelHeight = panel?.offsetHeight || 48;
  const maxX = Math.max(0, window.innerWidth - panelWidth - 8);
  const maxY = Math.max(0, window.innerHeight - panelHeight - 8);

  return {
    x: Math.min(Math.max(8, nextPosition.x), maxX),
    y: Math.min(Math.max(8, nextPosition.y), maxY),
  };
}

function storePosition() {
  window.localStorage.setItem(positionStorageKey, JSON.stringify(position.value));
}

function toggleCollapsed() {
  isCollapsed.value = !isCollapsed.value;
  window.localStorage.setItem(collapsedStorageKey, String(isCollapsed.value));
  position.value = clampPosition(position.value);
  storePosition();
}

function onMessage(event: MessageEvent<MockLuaMessage>) {
  if (event.data.type !== "jo_minigame:mockLuaCallback") return;

  lastLuaCallback.value = JSON.stringify(event.data.data, null, 2);
}

function onDragStart(event: PointerEvent) {
  if (event.button !== 0) return;

  dragStart.value = {
    pointerId: event.pointerId,
    pointerX: event.clientX,
    pointerY: event.clientY,
    panelX: position.value.x,
    panelY: position.value.y,
  };

  panelRef.value?.setPointerCapture(event.pointerId);
}

function onDragMove(event: PointerEvent) {
  if (!dragStart.value) return;

  position.value = clampPosition({
    x: dragStart.value.panelX + event.clientX - dragStart.value.pointerX,
    y: dragStart.value.panelY + event.clientY - dragStart.value.pointerY,
  });
}

function onDragEnd(event: PointerEvent) {
  if (!dragStart.value) return;

  panelRef.value?.releasePointerCapture(event.pointerId);
  dragStart.value = null;
  storePosition();
}

function onResize() {
  position.value = clampPosition(position.value);
  storePosition();
}

onMounted(() => {
  readStoredPosition();
  isCollapsed.value = window.localStorage.getItem(collapsedStorageKey) === "true";
  window.addEventListener("message", onMessage);
  window.addEventListener("resize", onResize);
});

onBeforeUnmount(() => {
  window.removeEventListener("message", onMessage);
  window.removeEventListener("resize", onResize);
});
</script>

<template>
  <aside
    ref="panelRef"
    class="debug-panel"
    :class="{ collapsed: isCollapsed }"
    :style="panelStyle"
    @pointermove="onDragMove"
    @pointerup="onDragEnd"
    @pointercancel="onDragEnd"
  >
    <header class="debug-header" @pointerdown="onDragStart">
      <strong>Minigame Debug</strong>
      <button
        class="icon-button"
        type="button"
        @pointerdown.stop
        @click.stop.prevent="toggleCollapsed"
      >
        {{ isCollapsed ? "+" : "-" }}
      </button>
    </header>
    <div v-if="!isCollapsed" class="debug-body">
      <button type="button" @click="showLockpickMock">Show Lockpick</button>
      <button type="button" @click="hideMinigameMock">Hide Minigame</button>
      <pre>{{ lastLuaCallback }}</pre>
    </div>
  </aside>
</template>

<style scoped>
.debug-panel {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1000;
  display: grid;
  width: 220px;
  border: 1px solid rgb(255 255 255 / 16%);
  border-radius: 8px;
  color: #f6f7f9;
  background: rgb(22 25 29 / 92%);
  box-shadow: 0 12px 36px rgb(0 0 0 / 35%);
  font-family:
    Inter,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
}

.debug-panel.collapsed {
  width: 180px;
}

.debug-header {
  display: grid;
  grid-template-columns: 1fr 28px;
  align-items: center;
  gap: 8px;
  min-height: 40px;
  padding: 8px 8px 8px 12px;
  cursor: grab;
  user-select: none;
  touch-action: none;
}

.debug-header:active {
  cursor: grabbing;
}

.debug-body {
  display: grid;
  gap: 8px;
  padding: 0 12px 12px;
}

strong {
  font-size: 14px;
}

button {
  min-height: 34px;
  border: 0;
  border-radius: 6px;
  color: #101418;
  background: #e8edf3;
  font: inherit;
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}

.icon-button {
  display: grid;
  width: 28px;
  min-height: 28px;
  place-items: center;
  padding: 0;
  color: #f6f7f9;
  background: rgb(255 255 255 / 12%);
}

button:hover {
  filter: brightness(1.08);
}

pre {
  min-height: 42px;
  max-height: 140px;
  margin: 0;
  padding: 8px;
  overflow: auto;
  border-radius: 6px;
  color: #d8dee7;
  background: #0d0f12;
  font-size: 12px;
  line-height: 1.35;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>
