<template>
  <!--
    The overlay is the only element allowed to use viewport units: it must cover
    the screen whatever the scale. The container below holds every px dimension
    and carries the scaling, so the whole panel keeps the proportions it was
    designed with on a 1080p viewport.
  -->
  <div class="input-overlay">
    <div ref="container" v-ui-scaler="'center center'" class="input-container">
      <div class="input-backdrop" aria-hidden="true">
        <span
          v-for="patch in BACKDROP_PATCHES"
          :key="patch"
          class="input-backdrop__patch"
          :class="patch"
        />
      </div>
      <!--
        The three zones a row can be sent to. Each one is rendered only when it
        holds something, otherwise the gap of the container would leave a hole.
      -->
      <div v-if="inputStore.headerRows.length" class="input-header">
        <InputRow
          v-for="(row, rowIndex) in inputStore.headerRows"
          :key="rowIndex"
          :row="row"
          @submit="submitFromField"
        />
      </div>
      <div v-if="inputStore.contentRows.length" class="input-content">
        <InputRow
          v-for="(row, rowIndex) in inputStore.contentRows"
          :key="rowIndex"
          :row="row"
          @submit="submitFromField"
        />
      </div>
      <div v-if="inputStore.footerRows.length" class="input-footer">
        <InputRow
          v-for="(row, rowIndex) in inputStore.footerRows"
          :key="rowIndex"
          :row="row"
          @submit="submitFromField"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from "vue";
import InputRow from "@/components/InputRow.vue";
import { useBackdropSize } from "@/composables/useBackdropSize";
import { useInputStore } from "@/stores/input";

const inputStore = useInputStore();

const container = ref<HTMLElement | null>(null);

useBackdropSize(() => container.value);

/** The nine patches of the backdrop, named by the cell they cover. */
const BACKDROP_PATCHES = ["left", "center", "right"].flatMap((column) =>
  ["top", "middle", "bottom"].map((row) => `is-${column} is-${row}`),
);

/**
 * Set while Enter is held down, so a key repeat cannot submit the next panel
 * opened by the same interaction.
 */
let ignoreEnter = false;

/** Shared gate between the field-level Enter and the global one. */
function acceptsEnter(): boolean {
  if (ignoreEnter) return false;

  if (inputStore.isEnterGuarded()) {
    ignoreEnter = true;
    return false;
  }

  return true;
}

/** Enter pressed inside a field: submits whatever buttons the panel declares. */
function submitFromField() {
  if (!acceptsEnter()) return;

  inputStore.submit("Enter");
}

function onKeyDown(event: KeyboardEvent) {
  if (event.code === "Escape") {
    event.preventDefault();
    inputStore.cancel();
    return;
  }

  if (event.code !== "Enter") return;
  if (!acceptsEnter()) return;
  // A focused field handles its own Enter through the submit event.
  if (document.activeElement?.tagName !== "BODY") return;
  // With buttons on screen, the player is expected to pick one.
  if (inputStore.hasButton) return;

  inputStore.submit("Enter");
}

function onKeyUp(event: KeyboardEvent) {
  if (event.code === "Enter") ignoreEnter = false;
}

onMounted(() => {
  window.addEventListener("keydown", onKeyDown);
  window.addEventListener("keyup", onKeyUp);
});

onBeforeUnmount(() => {
  window.removeEventListener("keydown", onKeyDown);
  window.removeEventListener("keyup", onKeyUp);
});
</script>

<style scoped lang="scss">
.input-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--color-overlay);
}

.input-container {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 14px;
  width: var(--modal-width);
  max-height: var(--modal-max-height);
  padding: var(--padding-container);

  // The scroll owner is .input-content so the backdrop can keep the full
  // natural height of the panel instead of stopping at max-height.
  overflow: visible;
}

// Pinned zones: they never give up height, the content does it for them.
.input-header,
.input-footer {
  display: flex;
  flex-direction: column;
  gap: 14px;
  flex-shrink: 0;
}

.input-content {
  display: flex;
  flex-direction: column;
  gap: 14px;

  // `flex-basis: auto`, and not the `flex: 1` shorthand which resolves to a 0
  // basis: the container is auto-height, so a 0 basis would make this zone
  // contribute nothing to its intrinsic height and collapse the panel. With an
  // auto basis the panel still sizes to its content, and once
  // --modal-max-height caps it, `min-height: 0` lets this zone — and only this
  // one — shrink and scroll, which pushes the header and the footer apart.
  flex: 1 1 auto;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: auto;
}

// Painted backdrop, on its own layer.
//
// The mask lives on elements of its own rather than on .input-container: a mask
// clips the element *and its children*, so masking the container itself would
// cut off the select list and the calendar exactly like a scroll would.
//
// It sits behind the rows through `z-index: -1`, which stays inside the panel
// because the ui-scaler transform makes .input-container a stacking context.
//
// Same 9-patch idea as the title (see TitleEntry.vue) — corners kept, edges
// stretched — but cut by hand into nine elements instead of being handed to
// `mask-box-image`. That property draws the nine tiles edge to edge, each
// antialiased on its own, and wherever a tile does not measure a whole number
// of device pixels the two sides of a boundary compose to less than full
// opacity: a 1px lighter line runs across the panel. Here the patches overlap
// by --backdrop-overlap instead of merely touching, so there is no boundary
// left to leak through. The pixels they duplicate are deep inside the painted
// area, where the artwork is opaque and a couple of px of mismatch is invisible.
//
// bg.png is a plain white bitmap whose ragged edges only exist in its alpha, so
// it masks a flat fill rather than being painted: the colour keeps coming from
// the token.
.input-backdrop {
  // Intrinsic size of bg.png and the slice taken out of it. They describe the
  // bitmap, never the layout, hence SCSS constants rather than custom
  // properties; --modal-frame-width is their counterpart on the panel side.
  $source-width: 1024;
  $source-height: 972;
  $source-slice: 96;
  $source-middle-width: $source-width - $source-slice * 2;
  $source-middle-height: $source-height - $source-slice * 2;

  position: absolute;
  left: calc(var(--modal-bleed) * -1);
  top: calc(var(--modal-bleed) * -1);
  width: var(--backdrop-width, calc(100% + var(--modal-bleed) * 2));
  height: var(--backdrop-height, calc(100% + var(--modal-bleed) * 2));
  z-index: -1;
  pointer-events: none;

  &__patch {
    position: absolute;
    background-color: var(--color-background);
    -webkit-mask-image: url("/assets/ui/bg.png");
    -webkit-mask-repeat: no-repeat;
    -webkit-mask-size: var(--mask-width) var(--mask-height);
    -webkit-mask-position: var(--mask-x) var(--mask-y);

    // Corner columns and rows show the bitmap at its natural size, anchored to
    // their own edge, so the painted corners keep their pixels untouched.
    &.is-left {
      left: 0;
      width: calc(var(--modal-frame-width) + var(--backdrop-overlap));
      --mask-width: #{$source-width}px;
      --mask-x: 0px;
    }

    &.is-right {
      right: 0;
      width: calc(var(--modal-frame-width) + var(--backdrop-overlap));
      --mask-width: #{$source-width}px;
      --mask-x: calc(
        var(--modal-frame-width) + var(--backdrop-overlap) - #{$source-width}px
      );
    }

    &.is-top {
      top: 0;
      height: calc(var(--modal-frame-width) + var(--backdrop-overlap));
      --mask-height: #{$source-height}px;
      --mask-y: 0px;
    }

    &.is-bottom {
      bottom: 0;
      height: calc(var(--modal-frame-width) + var(--backdrop-overlap));
      --mask-height: #{$source-height}px;
      --mask-y: calc(
        var(--modal-frame-width) + var(--backdrop-overlap) - #{$source-height}px
      );
    }

    // The stretched band: the bitmap is blown up so its middle section alone
    // spans the gap between the two corners, then pulled back by the slice it
    // now measures, so that source edge and panel edge still coincide.
    &.is-center {
      left: calc(var(--modal-frame-width) - var(--backdrop-overlap));
      right: calc(var(--modal-frame-width) - var(--backdrop-overlap));
      --mask-width: calc(
        (var(--backdrop-width) - var(--modal-frame-width) * 2) * #{$source-width} /
          #{$source-middle-width}
      );
      --mask-x: calc(
        var(--backdrop-overlap) -
          (var(--backdrop-width) - var(--modal-frame-width) * 2) * #{$source-slice} /
          #{$source-middle-width}
      );
    }

    &.is-middle {
      top: calc(var(--modal-frame-width) - var(--backdrop-overlap));
      bottom: calc(var(--modal-frame-width) - var(--backdrop-overlap));
      --mask-height: calc(
        (var(--backdrop-height) - var(--modal-frame-width) * 2) * #{$source-height} /
          #{$source-middle-height}
      );
      --mask-y: calc(
        var(--backdrop-overlap) -
          (var(--backdrop-height) - var(--modal-frame-width) * 2) * #{$source-slice} /
          #{$source-middle-height}
      );
    }
  }
}
</style>
