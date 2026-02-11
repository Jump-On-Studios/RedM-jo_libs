<template>
    <div :class="['color-custom color-' + numberColor, props.color.style]" :key="keyUpdate">
        <div v-for="index in numberColor" :key="index" :class="'tint tint' + (index - 1)" :style="getStyleTint(index - 1)"></div>
        <div class="border"></div>
    </div>
</template>

<script setup>
import { computed, inject, ref, watch } from 'vue';
import { getPaletteColors } from '../../services/paletteLoader'
const API = inject('API')
const props = defineProps(['color'])
const tint = computed(() => {
    if (props.color.rgb) {
        let rgb = props.color.rgb
        if (typeof rgb == 'string')
            return {
                palette: 'rgb',
                tints: rgb.split(',')
            }
        return {
            palette: 'rgb',
            tints: rgb
        }
    }
    if (props.color.tints) {
        return {
            palette: props.color.palette,
            tints: props.color.tints
        }
    }
    const tints = [props.color.tint0]
    if (Number.isInteger(props.color.tint1))
        tints.push(props.color.tint1)
    if (Number.isInteger(props.color.tint2))
        tints.push(props.color.tint2)
    return {
        palette: props.color.palette,
        tints: tints
    }
})

const numberColor = computed(() => { return tint.value.tints.length })

const keyUpdate = computed(() => {
    let key = ""
    if (tint.value.palette)
        key += tint.value.palette
    if (tint.value.tints)
        key += tint.value.tints.reduce((a, b) => a + b, 0)

    return key
})

const paletteColors = ref([])
const resolvedPaletteName = computed(() => {
    if (tint.value.palette == 'rgb') return ''
    return API.getPalette(tint.value.palette)
})

let paletteRequestId = 0
watch(resolvedPaletteName, async (paletteName) => {
    const requestId = ++paletteRequestId
    if (!paletteName) {
        paletteColors.value = []
        return
    }

    const colors = await getPaletteColors(paletteName)
    if (requestId !== paletteRequestId) return
    paletteColors.value = colors
}, { immediate: true })

function getStyleTint(index) {
    if (tint.value.palette == 'rgb')
        return {
            'background-color': tint.value.tints[index]
        }

    const value = Number(tint.value.tints[index])
    return {
        'background-color': paletteColors.value?.[value] || '#000000'
    }
}
</script>

<style lang="scss" scoped>
.color-custom {
    width: 3vh;
    height: 3vh;
    position: relative;
    display: flex;
    justify-content: center;
    align-items: center;

    .tint,
    .border {
        position: absolute;
        aspect-ratio: 1 / 1;
        background-size: cover;
        background-repeat: no-repeat;
    }

    &.color-1,
    &.color-3 {
        .tint0 {
            width: 100%;
        }

        .tint1 {
            width: 66%;
        }

        .tint2 {
            width: 33%;
        }
    }

    &.color-2 {
        .tint {
            width: 100%;
        }

        .tint1 {
            -webkit-mask-image: linear-gradient(-45deg, white 50%, transparent 50%);
        }
    }

    .border {
        width: 100%;
        background-image: url('/assets/images/tints/swatch_box.png');
        background-position: center;
    }

    &.vertical-lines {
        display: flex;
        flex-direction: column;

        .tint {
            width: 100%;
            flex: 1;
            -webkit-mask-size: 100%;
        }

        &.color-2 {
            .tint1 {
                -webkit-mask-image: linear-gradient(transparent 50%, white 50%);
            }
        }

        &.color-3 {
            .tint1 {
                -webkit-mask-image: linear-gradient(transparent 33%, white 33%, white 66%, transparent 66%);
            }

            .tint2 {
                -webkit-mask-image: linear-gradient(transparent 66%, white 66%);
            }
        }
    }
}

.sprites .color-custom .border {
    display: none;
}
</style>
