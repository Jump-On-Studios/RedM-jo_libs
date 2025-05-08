<template>
  <ColorPaletteBox :color="{ palette: getPalette(), tint0: getTint(0), tint1: getTint(1), tint2: getTint(2) }" />
</template>

<script setup>
import ColorPaletteBox from './ColorPaletteBox.vue';

const props = defineProps(['sliders'])

function getPalette() {
  for (let index = 0; index < props.sliders.length; index++) {
    const slider = props.sliders[index];
    if (slider.type == "palette")
      return slider.tint
  }
  return ""
}

function getTint(index) {
  let slider

  let counter = 0
  for (let i = 0; i < props.sliders.length; i++) {
    slider = props.sliders[i];
    if (slider.type == "palette") {
      if (counter == index)
        return slider.current
      counter++
    }
  }
  return false
}
</script>